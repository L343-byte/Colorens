import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:colorlens/config/theme.dart';
import 'package:colorlens/config/routes.dart';
import 'package:colorlens/models/test_result_model.dart';
import 'package:colorlens/providers/test_provider.dart';
import 'package:colorlens/widgets/test/result_chart_widget.dart';
import 'package:colorlens/widgets/common/custom_button.dart';

class HRRResultScreen extends StatelessWidget {
  const HRRResultScreen({super.key});

  String _cvdTypeName(String? type) {
    if (type == null) return 'Tidak diketahui';
    switch (type.toLowerCase()) {
      case 'protan':
        return 'Protan (Gangguan Merah)';
      case 'deutan':
        return 'Deutan (Gangguan Hijau)';
      case 'tritan':
        return 'Tritan (Gangguan Biru)';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final result = (args is TestResultModel)
        ? args
        : context.watch<TestProvider>().result;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Hasil Tes HRR'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 72,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum Ada Hasil Tes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan selesaikan tes HRR terlebih dahulu untuk melihat hasil analisis lengkap.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Mulai Tes HRR',
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.hrrTest);
                  },
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Kembali ke Beranda',
                  isOutlined: true,
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    Color statusColor;
    IconData statusIcon;
    switch (result.severity.toLowerCase()) {
      case 'normal':
        statusColor = AppTheme.tealSuccess;
        statusIcon = Icons.check_circle;
        break;
      case 'mild':
        statusColor = AppTheme.warningYellow;
        statusIcon = Icons.warning;
        break;
      case 'moderate':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case 'severe':
      default:
        statusColor = AppTheme.errorRed;
        statusIcon = Icons.warning;
        break;
    }

    final Map<String, int> correctPerType = {};
    final Map<String, int> totalPerType = {};

    for (var answer in result.answers) {
      final typeStr = answer['cvdType'] ?? 'Lainnya';
      final typeLabel = _cvdTypeName(typeStr);

      totalPerType[typeLabel] = (totalPerType[typeLabel] ?? 0) + 1;
      if (answer['isCorrect'] == true) {
        correctPerType[typeLabel] = (correctPerType[typeLabel] ?? 0) + 1;
      }
    }

    final Map<String, double> scores = {};
    for (var type in totalPerType.keys) {
      final total = totalPerType[type] ?? 0;
      final correct = correctPerType[type] ?? 0;
      scores[type] = total > 0 ? (correct / total) : 0.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Tes HRR'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(statusIcon, color: Colors.white, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Status: ${result.diagnosis}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (result.cvdType != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Jenis: ${_cvdTypeName(result.cvdType)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Skor Anda',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${result.score}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  Text(
                    ' / ${result.totalQuestions}',
                    style: const TextStyle(fontSize: 24, color: Colors.grey),
                  ),
                ],
              ),
              Text(
                '${result.percentage.toStringAsFixed(0)}% benar',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'Performa per Area Warna',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ResultChartWidget(scores: scores),
              const SizedBox(height: 24),
              const Text(
                'Detail Jawaban',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...result.answers.asMap().entries.map((entry) {
                final index = entry.key;
                final answer = entry.value;
                final isCorrect = answer['isCorrect'] == true;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCorrect
                          ? AppTheme.tealSuccess
                          : AppTheme.errorRed,
                      child: Icon(
                        isCorrect ? Icons.check : Icons.close,
                        color: Colors.white,
                      ),
                    ),
                    title: Text('Soal ${index + 1}'),
                    subtitle: Text('Jawaban: ${answer['userAnswer']}'),
                    trailing: isCorrect
                        ? null
                        : Text(
                            'Kunci: ${answer['correctAnswer']}',
                            style: const TextStyle(
                              color: AppTheme.errorRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Hasil ini bersifat screening awal dan bukan diagnosis medis resmi. Konsultasikan ke dokter mata untuk pemeriksaan lebih lanjut.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Kembali ke Beranda',
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 8),
              CustomButton(
                text: 'Tes Ulang',
                isOutlined: true,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.hrrTest);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
