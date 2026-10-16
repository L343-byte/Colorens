import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:colorlens/app.dart';
import 'package:colorlens/providers/auth_provider.dart';
import 'package:colorlens/providers/test_provider.dart';
import 'package:colorlens/providers/camera_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase secara aman (pada Android membaca google-services.json)
  try {
    if (!kIsWeb) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase belum aktif atau dalam mode offline: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TestProvider()),
        ChangeNotifierProvider(create: (_) => CameraProvider()),
      ],
      child: const ColorlensApp(),
    ),
  );
}
