import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/app_theme.dart';
import 'features/auth/views/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Production Error Handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // You could send to Sentry/Firebase here
    debugPrint('Global Error: ${details.exception}');
  };

  ErrorWidget.builder = (details) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(24),
        color: AppColors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 64),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'We encountered an unexpected error. Our team has been notified.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey400, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.offAll(() => const SplashScreen()),
              child: const Text('Restart App'),
            ),
          ],
        ),
      ),
    );
  };

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const FlirtifyApp());
}

class FlirtifyApp extends StatelessWidget {
  const FlirtifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flirtify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
