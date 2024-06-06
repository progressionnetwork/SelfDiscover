import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path_provider/path_provider.dart';
import 'package:self_discover/screens/result_screen.dart';
import 'package:self_discover/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/api_service.dart';
import '../widgets/markdown_view.dart';
import 'about_screen.dart';


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController GroqapiKeyController = TextEditingController();
  final TextEditingController proxyController = TextEditingController();

  String apiKey = 'YOUR_API_KEY';
  String GroqapiKey = 'YOUR_GROQ_API_KEY';
  String proxy = 'VALID PROXY';
  bool useVpn = true;
  String selectedModel = 'gpt-3.5-turbo';
  String selectedLanguage = 'English';
  String selectedTheme = 'Light';
  String selectedAppLanguage = 'English';
  String selectedLogic = 'Self-Discover Agent';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final file = await _localFile;
    if (await file.exists()) {
      final contents = await file.readAsString();
      final jsonSettings = jsonDecode(contents);

      setState(() {
        apiKey = jsonSettings['apiKey'];
        GroqapiKey = jsonSettings['GroqapiKey'];
        proxy = jsonSettings['proxy'];
        selectedModel = jsonSettings['selectedModel'];
        selectedLanguage = jsonSettings['selectedLanguage'];
        selectedTheme = jsonSettings['selectedTheme'];
        selectedAppLanguage = jsonSettings['selectedAppLanguage'];
        useVpn = jsonSettings['useVpn'];
      });
    }
  }

  Future<void> _saveSettings() async {
    final file = await _localFile;

    final jsonSettings = jsonEncode({
      'apiKey': apiKey,
      'GroqapiKey': GroqapiKey,
      'proxy': proxy,
      'selectedModel': selectedModel,
      'selectedLanguage': selectedLanguage,
      'selectedTheme': selectedTheme,
      'selectedAppLanguage': selectedAppLanguage,
      'useVpn': useVpn,
    });

    await file.writeAsString(jsonSettings);
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/settings.json');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Invalid Input'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _pasteText(String text) {
    _controller.text = text;
  }

  void _clearText() {
    _controller.clear();
  }

  void _checkApiKeyAndProceed() async {
    final question = _controller.text;

    if (question.isEmpty) {
      _showErrorDialog('The question cannot be empty.');
    } else if (question.length < 10) {
      _showErrorDialog('The question must be at least 10 characters long.');
    } else if (question.length > 350) {
      _showErrorDialog('The question cannot be more than 350 characters long.');
    } else {
      if (apiKey.isEmpty || !apiKey.startsWith('sk-')) {
        // Navigate to options screen if API key is not set or invalid
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OptionsScreen(
              selectedModel: selectedModel,
              selectedLanguage: selectedLanguage,
              selectedTheme: selectedTheme,
              selectedAppLanguage: selectedAppLanguage,
              apiKey: apiKeyController.text,
              GroqapiKey: GroqapiKeyController.text,
              proxy: proxyController.text,
              useVpn: useVpn,
            ),
          ),
        );

        if (result != null) {
          setState(() {
            apiKey = result['apiKey'];
            GroqapiKey = result['GroqapiKey'];
            selectedModel = result['selectedModel'];
            selectedLanguage = result['selectedLanguage'];
            selectedTheme = result['selectedTheme'];
            selectedAppLanguage = result['selectedAppLanguage'];
            proxy = result['proxy'];
          });
          _saveSettings();
        }
      } else {
        // Proceed to the result screen if API key is valid
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              question: _controller.text,
              apiKey: apiKey,
              GroqapiKey: GroqapiKey,
              useVpn: useVpn,
              model: selectedModel,
              language: selectedLanguage,
              proxy: proxy,
              logic: selectedLogic,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Self-Discover / GPT-Researcher App'),
        actions: [
          IconButton(
            icon: Icon(Icons.question_mark_outlined),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OptionsScreen(
                    selectedModel: selectedModel,
                    selectedLanguage: selectedLanguage,
                    selectedTheme: selectedTheme,
                    selectedAppLanguage: selectedAppLanguage,
                    apiKey: apiKey,
                    GroqapiKey: GroqapiKey,
                    proxy: proxy,
                    useVpn: useVpn,
                  ),
                ),
              );

              if (result != null) {
                setState(() {
                  selectedModel = result['selectedModel'];
                  selectedLanguage = result['selectedLanguage'];
                  selectedTheme = result['selectedTheme'];
                  selectedAppLanguage = result['selectedAppLanguage'];
                  apiKey = result['apiKey'];
                  GroqapiKey = result['GroqapiKey'];
                  proxy = result['proxy'];
                });
                _saveSettings();
              }
            },
          ),
        ],
      ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Add a logo at the top
                Center(
                  child: Image.asset(
                    'assets/logo.png', // Make sure to add your logo image to the assets folder and update the path here
                    height: 250, // Adjust the size according to your needs
                  ),
                ),
                SizedBox(height: 20.0),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Self-Discover Agent',
                  ),
                  items: [
                    DropdownMenuItem(value: 'Self-Discover Agent', child: Text('Self-Discover Agent')),
                    DropdownMenuItem(value: 'Basic question', child: Text('Basic question')),
                    DropdownMenuItem(value: 'GPT Researcher Agent', child: Text('GPT Researcher Agent')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedLogic = value!;
                    });
                  },
                ),
                SizedBox(height: 20),
                // TextField with clear button
                Stack(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask your question...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: _clearText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                CustomButton(
                  text: 'Execute',
                  onPressed: _checkApiKeyAndProceed,
                ),
                SizedBox(height: 26.0),
                const Text('Examples: '),
                SizedBox(height: 6.0),
                GestureDetector(
                  onTap: () => _pasteText(
                    'Как накачать здоровое и красивое тело за 90 дней, опиши лучшие методики, дополнительные фишки, такие как дыхательные упражнения, спортивное питание?',
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      'Как накачать здоровое и красивое тело за 90 дней, опиши лучшие методики, дополнительные фишки, такие как дыхательные упражнения, спортивное питание?',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 6.0),
                GestureDetector(
                  onTap: () => _pasteText(
                    'Расскажи детально о применении пиявок для лечения позвоночника человека, опиши плюсы и минусы, риски и положительные стороны. напиши как выбирать пиявок, где купить, сколько раз их можно использовать, как долго они живут',
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      'Расскажи детально о применении пиявок для лечения позвоночника человека, опиши плюсы и минусы, риски и положительные стороны. напиши как выбирать пиявок, где купить, сколько раз их можно использовать, как долго они живут',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 6.0),
                GestureDetector(
                  onTap: () => _pasteText(
                    'How to be more smart and productive with using meditation and affirmations?',
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      'How to be more smart and productive with using meditation and affirmations?',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class OptionsScreen extends StatefulWidget {
  final String selectedModel;
  final String selectedLanguage;
  final String selectedTheme;
  final String selectedAppLanguage;
  final String apiKey;
  final String GroqapiKey;
  final String proxy;
  final bool useVpn;

  OptionsScreen({
    required this.selectedModel,
    required this.selectedLanguage,
    required this.selectedTheme,
    required this.selectedAppLanguage,
    required this.apiKey,
    required this.GroqapiKey,
    required this.proxy,
    required this.useVpn,
  });

  @override
  _OptionsScreenState createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  late TextEditingController apiKeyController;
  late TextEditingController GroqapiKeyController;
  late TextEditingController proxyController;
  late String selectedModel;
  late String selectedLanguage;
  late String selectedTheme;
  late String selectedAppLanguage;
  late bool useVpn;
  bool isApiKeyValid = true;
  bool isGroqApiKeyValid = true;
  bool isProxyValid = true;

  bool validateApiKey(String apiKey) {
    return apiKey.startsWith('sk-');
  }

  bool validateGroqApiKey(String apiKey) {
    return apiKey.startsWith('gsk_');
  }

  bool validateProxy(String proxy) {
    final proxyPattern =
        r'^(http:\/\/|https:\/\/)?([a-zA-Z0-9\-_]+(\.[a-zA-Z0-9\-_]+)+(:[0-9]+)?(\/.*)?)?$';
    final regExp = RegExp(proxyPattern);
    return regExp.hasMatch(proxy);
  }

  @override
  void initState() {
    super.initState();
    apiKeyController = TextEditingController(text: widget.apiKey);
    GroqapiKeyController = TextEditingController(text: widget.GroqapiKey);
    proxyController = TextEditingController(text: widget.proxy);
    selectedModel = widget.selectedModel;
    selectedLanguage = widget.selectedLanguage;
    selectedTheme = widget.selectedTheme;
    selectedAppLanguage = widget.selectedAppLanguage;
    useVpn = widget.useVpn;
  }

  Future<void> _testApiKey() async {
    final message = "Write 'testing model'. Answer 'Test PASSED!' only.";
    try {
      final response = await ApiService.sendMessageToLLM(message, widget.apiKey, widget.proxy, widget.useVpn);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('LLM Response: $response')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _testGroqApiKey() async {
    final message = "Write 'testing model'. Answer 'Test PASSED!' only.";
    try {
      final response = await ApiService.sendMessageToLLM(message, widget.apiKey, widget.proxy, widget.useVpn);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('LLM Response: $response')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _saveSettings() {
    setState(() {
      isApiKeyValid = validateApiKey(apiKeyController.text);
      isGroqApiKeyValid = validateGroqApiKey(GroqapiKeyController.text);
      isProxyValid = useVpn ? true : validateProxy(proxyController.text);
    });

    if (isApiKeyValid && isProxyValid || isGroqApiKeyValid && isProxyValid) {
      Navigator.pop(context, {
        'proxy': proxyController.text,
        'apiKey': apiKeyController.text,
        'GroqapiKey': GroqapiKeyController.text,
        'selectedModel': selectedModel,
        'selectedLanguage': selectedLanguage,
        'selectedTheme': selectedTheme,
        'selectedAppLanguage': selectedAppLanguage,
        'useVpn': useVpn,
      });
    }
  }

  void _showAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert!'),
          content: Text('Your IP address indicates that you are from Russia. API key may be banned! Use VPN or proxy!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkUserCountry() async {
    try {
      final country = await GeoService.getUserCountry();
      if (country == 'RU' || country == 'Russia') {
        _showAlert();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You country by your IP location: $country')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking IP location: $e')),
      );
    }
  }

  Future<void> _checkModelSelection() async {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The selected model is expensive. It can cost 10+ cents for a single self-discover request.')),
        );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: apiKeyController,
              decoration: InputDecoration(
                labelText: 'OpenAI API Key',
                hintText: 'Enter your OpenAI API key',
                errorText: isApiKeyValid ? null : 'Invalid OpenAI API Key',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              key: Key('testButton'),
              onPressed: _testApiKey,
              child: Text('Test OpenAI API Key'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: GroqapiKeyController,
              decoration: InputDecoration(
                labelText: 'Groq API Key',
                hintText: 'Enter your Groq API key',
                errorText: isGroqApiKeyValid ? null : 'Invalid Groq API Key',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              key: Key('test2Button'),
              onPressed: _testApiKey,
              child: Text('Test Groq API Key'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: proxyController,
              decoration: InputDecoration(
                labelText: 'Valid Proxy',
                hintText: 'Enter valid proxy as http://ip:port',
                errorText: isProxyValid ? null : 'Invalid Proxy',
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Use VPN'),
                Switch(
                  value: useVpn,
                  onChanged: (value) {
                    setState(() {
                      useVpn = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _checkUserCountry,
              child: Text('Test Connection'),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: selectedModel,
              onChanged: (value) {
                setState(() {
                  selectedModel = value!;
                  if (selectedModel == 'gpt-4.0o') {
                    _checkModelSelection();
                  }
                });
              },
              items: ['gpt-3.5-turbo', 'gpt-4.0o', 'llama3-8b-8192', 'mixtral-8x7b-32768', 'gemma-7b-it'].map((model) {
                return DropdownMenuItem<String>(
                  value: model,
                  child: Text(model),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Model',
              ),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: selectedLanguage,
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
              },
              items: ['English', 'Russian', 'Chinese'].map((language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'LLM Answers Language',
              ),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: selectedTheme,
              onChanged: (value) {
                themeManager.toggleTheme();
                setState(() {
                  selectedTheme = value!;
                });
              },
              items: ['Light', 'Dark'].map((theme) {
                return DropdownMenuItem<String>(
                  value: theme,
                  child: Text(theme),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Theme',
              ),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: selectedAppLanguage,
              onChanged: (value) {
                setState(() {
                  selectedAppLanguage = value!;
                });
              },
              items: ['English', 'Russian', 'Chinese'].map((appLanguage) {
                return DropdownMenuItem<String>(
                  value: appLanguage,
                  child: Text(appLanguage),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'App Language',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
