import 'package:flutter/material.dart';
import 'package:colorlens/config/theme.dart';

/// Displays the current progress in a test.
class TestProgressIndicator extends StatelessWidget {
  final int current;
  final int total;

  const TestProgressIndicator({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current + 1) / total;
    final percentage = (progress * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Soal ${current + 1} dari $total',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryNavy,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
