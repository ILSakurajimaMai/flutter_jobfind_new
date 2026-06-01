// File chạy chính của ứng dụng Flutter.
// Khởi tạo Riverpod ProviderScope và định tuyến ban đầu của App.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_jobfind/features/auth/views/splash_screen.dart';
import 'package:app_jobfind/features/auth/views/login_screen.dart';

/// NavigatorKey toàn cục – dùng để navigate từ ApiClient khi 401 (không có BuildContext)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    // Bọc MyApp bằng ProviderScope để Riverpod hoạt động
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'JobFind App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter', // Assuming modern font
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF14003E)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {'/login': (_) => const LoginScreen()},
    );
  }
}
