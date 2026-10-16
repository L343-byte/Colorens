import 'package:flutter/material.dart';
import 'package:colorlens/config/theme.dart';

/// A loading overlay widget that blocks interaction when loading.
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          AbsorbPointer(
            absorbing: true,
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryNavy,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
