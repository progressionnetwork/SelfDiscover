import 'package:flutter/material.dart';
import 'package:self_discover/models/insight.dart';
import '../services/api_service.dart';
import '../services/proxy.dart'; // Ensure you have your API service
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String initialQuestion;
  final String apiKey;
  final bool useVpn;
  final String proxy;
  final Insight insight;

  ChatScreen({
    required this.apiKey,
    required this.proxy,
    required this.useVpn,
    required this.initialQuestion,
    required this.insight,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();

    if (widget.initialQuestion.isNotEmpty) {
      _sendMessage(widget.initialQuestion);
    }
  }

  void _sendMessage(String message) async {
    setState(() {
      _messages.add({'sender': 'user', 'message': message});
      _isLoading = true;
    });

    try {
      final response = await ApiService.sendMessageToLLM(message, widget.apiKey, widget.proxy, widget.useVpn);
      setState(() {
        _messages.add({'sender': 'bot', 'message': response});
      });
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'bot', 'message': 'Failed to get response'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey[700],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['message']!,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          message['sender']!,
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final message = _controller.text;
                    if (message.isNotEmpty) {
                      _controller.clear();
                      _sendMessage(message);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}