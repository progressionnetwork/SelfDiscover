import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:self_discover/services/proxy.dart';
import 'groq_api.dart';

// Cumulative variables to track total tokens and cost
int totalPromptTokens = 0;
int totalCompletionTokens = 0;
int totalTokens = 0;
double totalCost = 0.0;

// Pricing for different models
const Map<String, double> modelPrices = {
  'gpt-3.5-turbo-prompt': 0.50 / 1e6, // $0.50 per 1M tokens
  'gpt-3.5-turbo-completion': 1.50 / 1e6, // $1.50 per 1M tokens
  'gpt-4o-prompt': 5.00 / 1e6, // $5.00 per 1M tokens
  'gpt-4o-completion': 15.00 / 1e6, // $15.00 per 1M tokens
};

class ApiService {
  final String apiKey;
  final String GroqapiKey;
  final String proxy;
  final bool useVpn;
  final String selectedModel;
  final String selectedLanguage;

  ApiService({
    required this.apiKey,
    required this.GroqapiKey,
    required this.proxy,
    required this.useVpn,
    required this.selectedModel,
    required this.selectedLanguage,
  });

  // Function to save JSON data to a file
  Future<void> saveJsonToFile(
      Map<String, dynamic> data, String filename) async {
    try {
      // Get the directory to store the file
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$filename';

      // Convert the data to a JSON string
      final jsonString = jsonEncode(data);

      // Write the JSON string to the file
      final file = File(path);
      await file.writeAsString('$jsonString\n',
          mode: FileMode.append, encoding: utf8);

      print("File saved/appended successfully at $path");
    } catch (e) {
      print("Error saving file: $e");
    }
  }

  static Future<String> sendMessageToLLM(
      String message, String apiKey, String proxy, bool useVpn) async {
    // Prepare the messages list
    List<Map<String, String>> messages = [
      {'role': 'user', 'content': message}
    ];

    // API key and endpoint
    String apiUrl = 'https://api.openai.com/v1/chat/completions';

    // Initialize the HTTP client based on the useVpn flag
    http.Client client;
    if (useVpn) {
      client = http.Client();
    } else {
      client = CustomHttpClient(proxy, http.Client()).createClient();
    }

    // Attempt to query the LLM
    while (true) {
      try {
        final response = await client.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: json.encode({
            'model': 'gpt-3.5-turbo', //'gpt-4o', //'gpt-3.5-turbo',
            'messages': messages,
            'temperature': 0.7,
            'max_tokens': 2048,
            'n': 1,
          }),
        );

        print(json.decode(response.body));
        if (response.statusCode == 200) {
          final data = json.decode(utf8.decode(response.bodyBytes));
          return data['choices'][0]['message']['content'].trim();
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        print("Failure querying the AI. Retrying...");
        await Future.delayed(Duration(seconds: 1));
      }
    }
  }

  Future<String> queryLLM(List<Map<String, String>> messages,
      {int maxTokens = 2048, double temperature = 0.1}) async {
    // Initialize the HTTP client based on the useVpn flag
    http.Client client;
    if (useVpn) {
      client = http.Client();
    } else {
      client = CustomHttpClient(proxy, http.Client()).createClient();
    }

    // Stub to increase final context size
    for (var message in messages) {
      for (var value in message.values) {
        if (value.contains('providing your final answer as markdown')) {
          maxTokens = 4096;
          break;
        }
      }
    }

    // Check proxy connection only if not using VPN
    if (!useVpn) {
      bool isProxyAlive =
          await CustomHttpClient(proxy, http.Client()).checkProxyConnection();
      if (!isProxyAlive) {
        debugPrint('Proxy error!');
        return '';
      } else {
        debugPrint('Proxy is ok!');
      }
    }

    while (true) {
      try {
        final response = await client.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: json.encode({
            'model': selectedModel, //'gpt-4o',
            'messages': messages,
            'temperature': temperature,
            'max_tokens': maxTokens,
            'n': 1,
          }),
        );

        print(json.decode(response.body));
        if (response.statusCode == 200) {
          final data = json.decode(utf8.decode(response.bodyBytes));
          // Save the response to a JSON file
          await saveJsonToFile(data, 'llm_response.json');

          // Extract token usage information
          final usage = data['usage'];
          final int promptTokens = usage['prompt_tokens'];
          final int completionTokens = usage['completion_tokens'];
          final int responseTotalTokens = usage['total_tokens'];

          // Determine the price based on the model used
          double promptPricePerToken = 0.0;
          double completionPricePerToken = 0.0;

          if (selectedModel == 'gpt-3.5-turbo') {
            promptPricePerToken = modelPrices['gpt-3.5-turbo-prompt']!;
            completionPricePerToken = modelPrices['gpt-3.5-turbo-completion']!;
          } else if (selectedModel == 'gpt-4o') {
            promptPricePerToken = modelPrices['gpt-4o-prompt']!;
            completionPricePerToken = modelPrices['gpt-4o-completion']!;
          }

          // Calculate cost for the current request
          final costForThisRequest = (promptTokens * promptPricePerToken) + (completionTokens * completionPricePerToken);

          // Update cumulative totals
          totalPromptTokens += promptTokens;
          totalCompletionTokens += completionTokens;
          totalTokens += responseTotalTokens;
          totalCost += costForThisRequest;

          print('Prompt Tokens: $promptTokens');
          print('Completion Tokens: $completionTokens');
          print('Total Tokens: $responseTotalTokens');
          print('Estimated Cost for this request: \$${costForThisRequest.toStringAsFixed(4)}');

          return data['choices'][0]['message']['content'].trim();
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        print("Failure querying the AI. Retrying...");
        await Future.delayed(Duration(seconds: 1));
      }
    }
  }

  Future<String> queryGroqLLM(List<Map<String, String>> messages,
      {int maxTokens = 2048, double temperature = 0.1}) async {
    // Initialize the HTTP client based on the useVpn flag
    http.Client client;
    if (useVpn) {
      client = http.Client();
    } else {
      client = CustomHttpClient(proxy, http.Client()).createClient();
    }

    // Check proxy connection only if not using VPN
    if (!useVpn) {
      bool isProxyAlive =
      await CustomHttpClient(proxy, http.Client()).checkProxyConnection();
      if (!isProxyAlive) {
        debugPrint('Proxy error!');
        return '';
      } else {
        debugPrint('Proxy is ok!');
      }
    }

    while (true) {
      try {
        final response = await client.post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'), // Update endpoint
          headers: {
            'Authorization': 'Bearer $GroqapiKey',
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: json.encode({
            'model': selectedModel, // Use appropriate model for Groq API
            'messages': messages,
            'temperature': temperature,
            'max_tokens': maxTokens,
            'n': 1,
          }),
        );

        print(json.decode(response.body));
        if (response.statusCode == 200) {
          final data = json.decode(utf8.decode(response.bodyBytes));
          // Save the response to a JSON file
          await saveJsonToFile(data, 'llm_response.json');

          return data['choices'][0]['message']['content'].trim();
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        print("Failure querying the AI. Retrying...");
        await Future.delayed(Duration(seconds: 1));
      }
    }
  }

  Future<String> queryOpenAI(String prompt) async {
    List<Map<String, String>> messages = [
      {"role": "user", "content": prompt}
    ];
    switch (selectedModel) {
      case 'llama3-8b-8192':
      case 'mixtral-8x7b-32768':
      case 'gemma-7b-it':
        return await queryGroqLLM(messages);
      case 'gpt-3.5-turbo':
      case 'gpt-4.0o':
        return await queryLLM(messages);
      default:
        throw UnimplementedError('Model $selectedModel is not supported');
    }
  }

  Future<String> selectReasoningModules(
      String taskDescription, List<String> reasoningModules) async {
    String prompt =
        "Given the task: $taskDescription, which of the following reasoning modules are relevant? Do not elaborate on why.\n\n${reasoningModules.join("\n")}";
    return await queryOpenAI(prompt);
  }

  Future<String> adaptReasoningModules(
      String selectedModules, String taskExample) async {
    String prompt =
        "Without working out the full solution, adapt the following reasoning modules to be specific to our task:\n$selectedModules\n\nOur task:\n$taskExample";
    return await queryOpenAI(prompt);
  }

  Future<String> implementReasoningStructure(
      String adaptedModules, String taskDescription) async {
    String prompt =
        "Without working out the full solution, create an actionable reasoning structure for the task using these adapted reasoning modules:\n$adaptedModules\n\nTask Description:\n$taskDescription";
    return await queryOpenAI(prompt);
  }

  Future<String> executeReasoningStructure(String reasoningStructure, String taskInstance) async {
    String prompt = "Using the following reasoning structure: $reasoningStructure\n\nSolve this task, providing your final answer as markdown in $selectedLanguage: $taskInstance"; // in Russian
    return await queryOpenAI(prompt);
  }

  Future<String> executeTranslationStructure(String reasoningStructure, String taskInstance) async {
    String prompt = "Using the following text: $reasoningStructure\n\nTranslate it to a $selectedLanguage";
    return await queryOpenAI(prompt);
  }

  Future<String> querySingleQuestion(String question) async {
    String prompt =
        "Using the following question: $question\n\n provide a detailed answer in $selectedLanguage: ";
    return await queryOpenAI(prompt);
  }
}

class CustomHttpClient {
  final String proxy;
  final http.Client client;

  CustomHttpClient(this.proxy, this.client);

  http.Client createClient() {
    // Logic to create an HTTP client that uses the proxy
    // This will vary depending on how you implement the proxy support
    return client;
  }

  Future<bool> checkProxyConnection() async {
    try {
      // Attempt a simple request to check the proxy
      final response = await client.get(Uri.parse(proxy));
      return response.statusCode == 200;
    } catch (e) {
      print("Proxy connection failed: $e");
      return false;
    }
  }
}

class GeoService {
  static Future<String> getUserCountry() async {
    final response = await http.get(Uri.parse('https://ipapi.co/country/'));

    if (response.statusCode == 200) {
      return response.body.trim();
    } else {
      throw Exception('Failed to load country');
    }
  }
}
