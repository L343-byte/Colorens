import 'package:flutter/material.dart';
import 'package:colorlens/config/theme.dart';

/// A simple bar chart widget to display color vision performance per area.
class ResultChartWidget extends StatelessWidget {
  final Map<String, double> scores;

  const ResultChartWidget({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: scores.entries.map((entry) {
        final label = entry.key;
        final value = entry.value;
        final percentage = (value * 100).toInt();

        Color barColor;
        if (percentage >= 80) {
          barColor = AppTheme.tealSuccess;
        } else if (percentage >= 60) {
          barColor = AppTheme.warningYellow;
        } else {
          barColor = AppTheme.errorRed;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(label, style: const TextStyle(fontSize: 14)),
              ),
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    minHeight: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 40,
                child: Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
