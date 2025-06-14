import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import '../services/api_service.dart';
import '../services/local_message_service.dart';
import '../services/remote_message_service.dart';
import '../models/message.dart';

class GroupChatScreen extends StatefulWidget {
  final String token;
  final int userId;
  final VoidCallback? onLogout;
  const GroupChatScreen(
      {super.key, required this.token, required this.userId, this.onLogout});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  List<Message> messages = [];
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool isRecording = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    loadLocalMessages();
    fetchAndSyncMessages();
    messageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadLocalMessages() async {
    setState(() {
      messages = LocalMessageService.getAllMessages();
    });
  }

  Future<void> fetchAndSyncMessages() async {
    setState(() {
      isLoading = true;
    });
    try {
      final lastId = LocalMessageService.getLastMessageId();
      final newMessages = await RemoteMessageService.fetchNewMessages(
          widget.token,
          afterId: lastId);
      await LocalMessageService.saveMessages(newMessages);
      setState(() {
        messages = LocalMessageService.getAllMessages();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      print('Error syncing messages: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}/groupchat/messages'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': text}),
      );
      if (response.statusCode == 200) {
        messageController.clear();
        await fetchAndSyncMessages();
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade300,
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.blue.shade400,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Group Chat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Tombol Logout
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: 'Logout',
                        onPressed: () async {
                          try {
                            await _apiService.logout(widget.token);
                            widget.onLogout?.call();
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Logout gagal: $e')),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Messages Container
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Date Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Today 5:01 PM',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      // Messages List
                      Expanded(
                        child: isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blue.shade400,
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final msg = messages[index];
                                  final isMe = msg.userId == widget.userId;
                                  return _buildMessageBubble(
                                    message: msg.message,
                                    userName: msg.userName ?? '',
                                    isMe: isMe,
                                    hasAudio: false,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // Input Container
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Gallery Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.photo, color: Colors.grey.shade600),
                        onPressed: () {},
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Message Input
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Voice/Send Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        icon: Icon(
                          messageController.text.isEmpty
                              ? Icons.mic
                              : Icons.send,
                          color: Colors.white,
                        ),
                        onPressed: messageController.text.isEmpty
                            ? () {
                                setState(() {
                                  isRecording = !isRecording;
                                });
                              }
                            : sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required String userName,
    required bool isMe,
    bool hasAudio = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.blue.shade400,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue.shade400 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  if (hasAudio) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_arrow,
                          color: isMe ? Colors.white : Colors.blue.shade400,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 100,
                          height: 20,
                          decoration: BoxDecoration(
                            color: (isMe ? Colors.white : Colors.blue.shade400)
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: List.generate(
                              20,
                              (index) => Container(
                                width: 2,
                                height: (index % 3 + 1) * 4.0,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Colors.white
                                      : Colors.blue.shade400,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '0:13',
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      message,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue.shade400,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
