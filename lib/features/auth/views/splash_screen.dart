// Màn hình Splash (màn hình khởi động ứng dụng).
// Gọi API hoặc kiểm tra trạng thái khởi chạy ban đầu.
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  /// Hiển thị biểu trưng lớn hoặc bộ nhận diện thương hiệu JobFind lúc vừa bật App
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF6F6F6,
      ), // Slightly off-white matching the design
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flexible Image Placeholder taking top space
              Expanded(
                flex: 3,
                child: Center(
                  child: Image.asset(
                    'assets/images/jobfinding.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title Text matching exactly the design
              const Text(
                'Find Your',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900, // Extra bold
                  height: 1.1,
                  color: Colors.black,
                  letterSpacing: -1, // Tighter letter spacing
                ),
              ),

              // "Dream Job" with custom underline
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFFDAE5C), // Orange color
                      width: 4.0, // Thick underline
                    ),
                  ),
                ),
                child: const Text(
                  'Dream Job',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    color: Color(0xFFFDAE5C),
                    letterSpacing: -1,
                  ),
                ),
              ),

              const Text(
                'Here!',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  color: Colors.black,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 40),

              // Next button at bottom right
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Color(0xFF14003E), // Dark Navy/Purple
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 35,
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
