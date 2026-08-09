import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart'; // Import for picking images and files
import 'package:file_picker/file_picker.dart'; // Import for picking files

class ChatbotFloatingPanel extends StatefulWidget {
  const ChatbotFloatingPanel({super.key});

  @override
  State<ChatbotFloatingPanel> createState() => _ChatbotFloatingPanelState();
}

class _ChatbotFloatingPanelState extends State<ChatbotFloatingPanel> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker(); // Add ImagePicker instance

  Future<void> _sendMessage(String message) async {
    setState(() {
      _isLoading = true;
      _messages.add({'user': message});
    });

    try {
      const String endpoint =
          'https://your-amplify-api-endpoint.amazonaws.com/chat';

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer your-auth-token',
        },
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Parse the response body
        setState(() {
          _messages.add({
            'bot': data['response'] ?? 'No response from server.',
          });
        });
      } else {
        setState(() {
          _messages.add({'bot': 'Error: Unable to fetch response.'});
        });
      }
    } catch (e) {
      setState(() {
        debugPrint("Error sending message: $e");
        _messages.add({'bot': 'Error: $e'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform
        .pickFiles(); // Allow picking any file type
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _messages.add({'user': 'Sent a file: ${file.name}'});
      });
      // Handle file upload or processing here
    }
  }

  Future<void> _sendMessageToBackend(String message) async {

    setState(() {
      _messages.add({'user': message});
      _isLoading = true;
    });

    try {
      const String endpoint =
          'https://m5kkr1om14.execute-api.us-east-1.amazonaws.com/prod/grok-mcp-server-e';

      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "jsonrpc": "2.0",
              "id": 1,
              "method": "tools/call",
              "params": {
                "name": "analyze_user_prompt",
                "arguments": {"user_prompt": message}
              }
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          if (responseData['result']["status"] == "rejected") {
            _messages.add({'bot': responseData['result']['message']});
            return;
          }
          _messages.add({
            'bot': responseData['result']['answer'] ?? 'No response from server.',
          });
        });
      } else {
        setState(() {
          _messages.add({'bot': 'Error: Unable to connect to the server.'});
        });
      }
    } catch (e, stackTrace) {
      setState(() {
        debugPrint("Error sending message to backend: $e");
        debugPrint("Stack trace: $stackTrace");
        _messages.add({'bot': 'Error: ${e.toString()}'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.containsKey('user');

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF2E2E3C),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      isUser ? message['user']! : message['bot']!,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF2E2E3C),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(
                    Icons.attach_file,
                    color: Colors.black,
                  ), // File attachment icon
                  onPressed:
                      _pickFile, // Updated to use FilePicker for all file types
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.black),
                  onPressed: () {
                    final message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      _messageController.clear();
                      _sendMessageToBackend(message); // Send message to backend
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
