import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:colorlens/config/routes.dart';
import 'package:colorlens/providers/test_provider.dart';
import 'package:colorlens/providers/auth_provider.dart';
import 'package:colorlens/data/hrr_data.dart';
import 'package:colorlens/widgets/test/progress_indicator_widget.dart';
import 'package:colorlens/widgets/test/answer_option_widget.dart';
import 'package:colorlens/widgets/common/custom_button.dart';
import 'package:colorlens/models/ishihara_plate_model.dart';

class HRRTestScreen extends StatefulWidget {
  const HRRTestScreen({super.key});

  @override
  State<HRRTestScreen> createState() => _HRRTestScreenState();
}

class _HRRTestScreenState extends State<HRRTestScreen> {
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TestProvider>().startHRRTest();
    });
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Yakin ingin keluar? Progres tes akan hilang.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Keluar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tes HRR'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ),
        body: Consumer<TestProvider>(
          builder: (context, testProvider, child) {
            final plates = testProvider.activeHRRPlates.isNotEmpty
                ? testProvider.activeHRRPlates
                : HRRTestData.plates;
            if (testProvider.currentIndex >= plates.length) {
              return const Center(child: CircularProgressIndicator());
            }

            final currentPlate = plates[testProvider.currentIndex];
            final isLastQuestion =
                testProvider.currentIndex == plates.length - 1;

            return SafeArea(
              child: Column(
                children: [
                  TestProgressIndicator(
                    current: testProvider.currentIndex,
                    total: plates.length,
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.06, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                      child: SingleChildScrollView(
                        key: ValueKey<int>(testProvider.currentIndex),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            Center(
                              child: Container(
                                width: 270,
                                height: 270,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: CustomPaint(
                                    size: const Size(254, 254),
                                    painter: _HRRPlateDotsPainter(
                                      dots: currentPlate.dots ?? const [],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Bentuk apa yang Anda lihat?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Pilih bentuk geometris yang tampak pada plate di atas',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ...currentPlate.options.map((option) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: AnswerOptionWidget(
                                  text: option,
                                  isSelected: _selectedAnswer == option,
                                  onTap: () {
                                    setState(() {
                                      _selectedAnswer = option;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 24),
                            CustomButton(
                              text: isLastQuestion
                                  ? 'Selesai & Lihat Hasil'
                                  : 'Lanjut Soal Berikutnya →',
                              onPressed: _selectedAnswer != null
                                  ? () async {
                                      final isCorrect =
                                          _selectedAnswer ==
                                          currentPlate.correctAnswer;
                                      testProvider.submitAnswer(
                                        plateId: currentPlate.id,
                                        userAnswer: _selectedAnswer!,
                                        correctAnswer:
                                            currentPlate.correctAnswer,
                                        isCorrect: isCorrect,
                                        cvdType: currentPlate.cvdType,
                                      );

                                      if (isLastQuestion) {
                                        final userId =
                                            context
                                                .read<AuthProvider>()
                                                .user
                                                ?.id ??
                                            'guest';
                                        final resultModel = testProvider
                                            .finishHRRTest(userId);
                                        await testProvider.saveResult(
                                          resultModel,
                                        );
                                        if (context.mounted) {
                                          Navigator.pushReplacementNamed(
                                            context,
                                            AppRoutes.hrrResult,
                                            arguments: resultModel,
                                          );
                                        }
                                      } else {
                                        testProvider.nextQuestion();
                                        setState(() {
                                          _selectedAnswer = null;
                                        });
                                      }
                                    }
                                  : null,
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HRRPlateDotsPainter extends CustomPainter {
  final List<DotData> dots;

  _HRRPlateDotsPainter({required this.dots});

  @override
  void paint(Canvas canvas, Size size) {
    // Background kartu putih bersih
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (final dot in dots) {
      dotPaint.color = dot.color;
      canvas.drawCircle(
        Offset(dot.x * size.width, dot.y * size.height),
        dot.radius * size.width,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HRRPlateDotsPainter oldDelegate) {
    return oldDelegate.dots != dots;
  }
}
