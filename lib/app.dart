import 'package:flutter/material.dart';
import 'package:colorlens/config/theme.dart';
import 'package:colorlens/config/routes.dart';
import 'package:colorlens/widgets/common/device_frame_wrapper.dart';

/// The main application widget for Colorlens.
class ColorlensApp extends StatelessWidget {
  /// Creates a [ColorlensApp].
  const ColorlensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colorlens',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return DeviceFrameWrapper(child: child);
      },
    );
  }
}
