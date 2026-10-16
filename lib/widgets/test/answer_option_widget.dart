import 'package:flutter/material.dart';
import 'package:colorlens/config/theme.dart';

/// An interactive option widget used in tests.
class AnswerOptionWidget extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool? isCorrect;
  final VoidCallback? onTap;

  const AnswerOptionWidget({
    super.key,
    required this.text,
    this.isSelected = false,
    this.isCorrect,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = AppTheme.surfaceWhite;
    Color borderColor = Colors.grey.shade300;
    Color textColor = AppTheme.textDark;

    const Color redBullet = Color(
      0xFFE53935,
    ); // Bulat Merah khas penanda opsi tes

    if (isCorrect != null) {
      if (isCorrect!) {
        backgroundColor = AppTheme.tealSuccess;
        borderColor = AppTheme.tealSuccess;
        textColor = AppTheme.surfaceWhite;
      } else {
        backgroundColor = AppTheme.errorRed;
        borderColor = AppTheme.errorRed;
        textColor = AppTheme.surfaceWhite;
      }
    } else if (isSelected) {
      backgroundColor = AppTheme.primaryNavy;
      borderColor = AppTheme.primaryNavy;
      textColor = AppTheme.surfaceWhite;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            // Bulat Merah pada setiap pemilihan jawaban
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : redBullet,
                  width: 2.2,
                ),
                color: isSelected
                    ? redBullet // Saat dipilih: Bulat merah solid
                    : Colors
                          .transparent, // Belum dipilih: Lingkaran bulat merah
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
