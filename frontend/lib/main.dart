import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/message.dart';
import 'login_screen.dart';
import 'group_chat_screen.dart';
import 'utils/auth_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MessageAdapter());
  await Hive.openBox<Message>('messages');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alumnet Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AuthFlow(),
    );
  }
}

class AuthFlow extends StatefulWidget {
  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  String? token;
  int? userId;
  bool isLoading = true;
  String? notif;
  bool isServerConnected = true;
  bool keepChecking = true;

  @override
  void initState() {
    super.initState();
    _startCheckingConnection();
  }

  void _startCheckingConnection() async {
    while (keepChecking) {
      final connected = await _checkServerConnection();
      if (connected) {
        setState(() {
          isServerConnected = true;
          isLoading = false;
        });
        keepChecking = false;
        await _checkAutoLogin();
        break;
      } else {
        setState(() {
          isServerConnected = false;
          isLoading = true;
        });
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  Future<void> _checkConnectionAndAutoLogin() async {
    final connected = await _checkServerConnection();
    if (!connected) {
      setState(() {
        isServerConnected = false;
        isLoading = false; // pastikan loading selesai agar SplashScreen tampil
      });
      return;
    }
    setState(() {
      isServerConnected = true;
    });
    await _checkAutoLogin();
  }

  Future<bool> _checkServerConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/'));
      return response.statusCode == 200 || response.statusCode == 404;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkAutoLogin() async {
    final login = await AuthStorage.getLogin();
    if (login != null) {
      final loginTime = login['loginTime'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      // 24 jam = 86400000 ms
      if (now - loginTime < 86400000) {
        // Cek token valid ke backend (opsional, di sini cek fetch messages)
        final valid = await _validateToken(login['token']);
        if (valid) {
          setState(() {
            token = login['token'];
            userId = login['userId'];
            isLoading = false;
          });
          return;
        } else {
          await AuthStorage.clearLogin();
          setState(() {
            notif = 'Sesi login sudah habis, silakan login ulang.';
          });
        }
      } else {
        await AuthStorage.clearLogin();
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<bool> _validateToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/groupchat/messages'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void _onLoginSuccess(String t, int id) async {
    await AuthStorage.saveLogin(t, id);
    setState(() {
      token = t;
      userId = id;
      notif = null;
    });
  }

  void _onLogout() async {
    await AuthStorage.clearLogin();
    setState(() {
      token = null;
      userId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isServerConnected) {
      return const SplashScreen(message: 'Connecting to server...');
    }
    if (isLoading) {
      return const SplashScreen(message: 'Establishing connection...');
    }
    if (token == null || userId == null) {
      return LoginScreen(
        onLoginSuccess: _onLoginSuccess,
        notif: notif,
      );
    } else {
      return GroupChatScreen(
          token: token!, userId: userId!, onLogout: _onLogout);
    }
  }
}
