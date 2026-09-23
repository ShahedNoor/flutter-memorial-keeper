import '../middleware/dio_logging_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();
  static late final Dio dio;
  static FirebaseAuth get firebaseAuth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  static String get baseUrl => _getBaseUrl();

  static Future<void> init() async {
    await Firebase.initializeApp();
    dio = Dio(
      BaseOptions(
        baseUrl: _getBaseUrl(),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(DioLoggingInterceptor());
  }

  static String _getBaseUrl() {
    return dotenv.get('API_BASE_URL', fallback: 'https://api.example.com');
  }
}
