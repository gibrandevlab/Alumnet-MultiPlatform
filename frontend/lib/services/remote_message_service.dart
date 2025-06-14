import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/message.dart';
import '../config.dart';

class RemoteMessageService {
  static Future<List<Message>> fetchNewMessages(String token,
      {int? afterId}) async {
    final url = afterId != null
        ? Uri.parse('$baseUrl/groupchat/messages?after_id=$afterId')
        : Uri.parse('$baseUrl/groupchat/messages');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Message.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch messages');
    }
  }
}
