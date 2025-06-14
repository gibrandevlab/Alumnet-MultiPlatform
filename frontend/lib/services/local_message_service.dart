import 'package:hive/hive.dart';
import '../models/message.dart';

class LocalMessageService {
  static Box<Message> getBox() => Hive.box<Message>('messages');

  static List<Message> getAllMessages() {
    final box = getBox();
    final messages = box.values.toList();
    messages.sort((a, b) => a.id.compareTo(b.id));
    return messages;
  }

  static int? getLastMessageId() {
    final box = getBox();
    if (box.isEmpty) return null;
    return box.values.map((m) => m.id).reduce((a, b) => a > b ? a : b);
  }

  static Future<void> saveMessages(List<Message> messages) async {
    final box = getBox();
    for (var msg in messages) {
      box.put(msg.id, msg);
    }
  }

  static Future<void> clearAll() async {
    await getBox().clear();
  }
}
