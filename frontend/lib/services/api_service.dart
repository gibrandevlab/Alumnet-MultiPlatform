import 'package:http/http.dart' as http;
import '../config.dart';

class ApiService {
  Future<String> fetchData() async {
    final response = await http.get(Uri.parse('$baseUrl/api/data'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load data from backend');
    }
  }

  Future<void> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to logout');
    }
  }
}
