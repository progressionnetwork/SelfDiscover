import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class Client {
  final String apiKey;
  final String baseUrl;
  final String version;

  Client({required this.apiKey, this.baseUrl = 'https://api.groq.com', this.version = 'v1'}) {
    // Initialize headers
  }

  Map<String, String> get headers => {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  Future<String> post(String endpoint, Map<String, dynamic> data) async {
    final String url = '$baseUrl/$version/$endpoint';
    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(data));
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody['choices'][0]['message']['content'];
      } else {
        throw HttpException('Failed to get response: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> streamPost(String endpoint, Map<String, dynamic> data) async {
    final String url = '$baseUrl/$version/$endpoint';
    final client = http.Client();
    final request = http.Request('POST', Uri.parse(url))
      ..headers.addAll(headers)
      ..body = jsonEncode(data);

    try {
      final response = await client.send(request);
      final fullResponse = StringBuffer();
      final completer = Completer<String>();

      response.stream.listen((chunk) {
        final responseText = utf8.decode(chunk);
        final jsonData = responseText.split('data: ')[1];
        final dataDict = jsonDecode(jsonData);

        if (dataDict['choices'][0]['delta'] != null) {
          final deltaContent = dataDict['choices'][0]['delta']['content'];
          stdout.write(deltaContent);
          fullResponse.write(deltaContent);
        } else if (dataDict['choices'][0]['finish_reason'] == 'stop') {
          completer.complete(fullResponse.toString());
        }
      }, onDone: () {
        if (!completer.isCompleted) {
          completer.complete(fullResponse.toString());
        }
      }, onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      });

      return completer.future;
    } finally {
      client.close();
    }
  }
}

class Chat {
  late Client client;

  void run({
    required String apiKey,
    String? model,
    String? prompt,
    String? systemPrompt,
    bool? stream,
    bool? json,
    double? temperature,
    int? maxTokens,
    double? topP,
    int? seed,
    List<String>? stop,
  }) async {
    client = Client(apiKey: apiKey);
    model = model ?? 'default_model';
    final conversationHistory = <Map<String, String>>[];

    if (systemPrompt != null) {
      conversationHistory.add({'role': 'system', 'content': systemPrompt});
    }

    while (true) {
      var userInput = prompt?.trim() ?? stdin.readLineSync()?.trim();
      prompt = null;

      if (userInput == null || userInput.toLowerCase() == 'exit' || userInput.toLowerCase() == 'quit') {
        print("\nThank you for using the Groq AI toolkit. Have a great day!");
        break;
      }

      if (userInput.isEmpty) {
        print("Invalid input detected. Please enter a valid message.");
        continue;
      }

      if (json == true) {
        if (stream == true) {
          print("Error: JSON mode does not support streaming.");
          exit(1);
        }
        if (stop != null) {
          print("Error: JSON mode does not support stop sequences.");
          exit(1);
        }
        if (!userInput.contains('json')) {
          userInput = '$userInput | Respond in JSON. The JSON schema should include at minimum: {"response": "string", "status": "string"}';
        }
      }

      conversationHistory.add({'role': 'user', 'content': userInput});

      final data = {
      'messages': conversationHistory,
      'model': model,
      if (temperature != null) 'temperature': temperature,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (topP != null)
        'top_p': topP,
        if (stream != null) 'stream': stream,
        if (seed != null) 'seed': seed,
        if (stop != null) 'stop': stop,
      };

      final endpoint = 'https://api.groq.com/openai/v1/chat/completions'; // Replace with the actual endpoint

      try {
        String assistantResponse;
        if (stream == true) {
          assistantResponse = await client.streamPost(endpoint, data);
        } else {
          assistantResponse = await client.post(endpoint, data);
        }

        print('Assistant: $assistantResponse');
        conversationHistory.add({'role': 'assistant', 'content': assistantResponse});
      } catch (e) {
        print('Error: $e');
      }
    }
  }
}

class Text {
  late Client client;

  void run({
    required String apiKey,
    String? model,
    required String prompt,
    String? systemPrompt,
    bool? stream,
    bool? json,
    double? temperature,
    int? maxTokens,
    double? topP,
    int? seed,
    List<String>? stop,
  }) async {
    client = Client(apiKey: apiKey);
    model = model ?? 'default_model';
    maxTokens = maxTokens ?? 1024;

    if (prompt.isEmpty) {
      print("Error: Invalid input detected. Please enter a valid message.");
      exit(1);
    }

    if (json == true) {
      if (stream == true) {
        print("Error: JSON mode does not support streaming.");
        exit(1);
      }
      if (stop != null) {
        print("Error: JSON mode does not support stop sequences.");
        exit(1);
      }
      if (!prompt.contains('json')) {
        prompt = '$prompt | Respond in JSON. The JSON schema should include at minimum: {"response": "string", "status": "string"}';
      }
    }

    final messages = <Map<String, String>>[
      if (systemPrompt != null) {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': prompt},
    ];

    final data = {
      'messages': messages,
      'model': model,
      if (temperature != null) 'temperature': temperature,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (topP != null) 'top_p': topP,
      if (stream != null) 'stream': stream,
      if (seed != null) 'seed': seed,
      if (stop != null) 'stop': stop,
    };

    final endpoint = 'https://api.groq.com/openai/v1/chat/completions'; // Replace with the actual endpoint

    try {
      String assistantResponse;
      if (stream == true) {
        assistantResponse = await client.streamPost(endpoint, data);
      } else {
        assistantResponse = await client.post(endpoint, data);
        print('Assistant: $assistantResponse');
      }

      print("\nThank you for using the Groq AI toolkit. Have a great day!");
    } catch (e) {
      print('Error: $e');
    }
  }
}

