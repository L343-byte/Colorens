import 'package:flutter/material.dart';
import 'package:colorlens/config/theme.dart';

/// Wraps the entire app in an authentic, sleek modern smartphone frame
/// when viewed on desktop browsers or wide displays, while providing full-screen
/// experience on real mobile devices.
class DeviceFrameWrapper extends StatefulWidget {
  final Widget child;

  const DeviceFrameWrapper({super.key, required this.child});

  @override
  State<DeviceFrameWrapper> createState() => _DeviceFrameWrapperState();
}

class _DeviceFrameWrapperState extends State<DeviceFrameWrapper> {
  bool _enableFrame = true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If running on a narrow screen (real phone or resized window < 550px),
        // render full-screen directly without double bezel.
        final bool isWideScreen = constraints.maxWidth >= 550;

        if (!isWideScreen || !_enableFrame) {
          return Stack(
            children: [
              widget.child,
              if (isWideScreen)
                Positioned(
                  top: 16,
                  right: 16,
                  child: _buildFrameToggleFloatingButton(),
                ),
            ],
          );
        }

        // Target smartphone dimensions (standard flagship: 393 x 852 px)
        const double phoneWidth = 393.0;
        const double phoneHeight = 852.0;
        const double bezelWidth = 12.0;
        const double cornerRadius = 50.0;
        const double innerRadius = 40.0;

        // Calculate available scale to guarantee the phone always fits cleanly on screen
        final double availableHeight = constraints.maxHeight - 80;
        final double scale = (availableHeight / (phoneHeight + bezelWidth * 2))
            .clamp(0.5, 1.0);

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: Stack(
            children: [
              // Subtle background ambient glow & grid
              Positioned.fill(
                child: CustomPaint(painter: _StudioBackgroundPainter()),
              ),

              // Top Control Bar
              Positioned(
                top: 12,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.phone_iphone,
                            color: AppTheme.accentGold,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Colorlens Mobile Simulator',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _buildFrameToggleButton(),
                  ],
                ),
              ),

              // Centered Smartphone Mockup Frame
              Center(
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: phoneWidth + bezelWidth * 2,
                    height: phoneHeight + bezelWidth * 2,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(cornerRadius),
                      border: Border.all(
                        color: const Color(0xFF475569),
                        width: 3.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 50,
                          spreadRadius: 8,
                          offset: const Offset(0, 20),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.08),
                          blurRadius: 10,
                          spreadRadius: -2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(bezelWidth),
                    child: Stack(
                      children: [
                        // Phone Screen Body
                        ClipRRect(
                          borderRadius: BorderRadius.circular(innerRadius),
                          child: Container(
                            color: Colors.white,
                            child: MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                padding: const EdgeInsets.only(
                                  top: 48,
                                  bottom: 24,
                                ),
                                viewPadding: const EdgeInsets.only(
                                  top: 48,
                                  bottom: 24,
                                ),
                              ),
                              child: widget.child,
                            ),
                          ),
                        ),

                        // Smartphone Dynamic Island & Speaker Top Notch
                        Positioned(
                          top: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 110,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Container(
                                      width: 11,
                                      height: 11,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF0F172A),
                                        border: Border.all(
                                          color: const Color(0xFF334155),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 44,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E293B),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Bottom Home Indicator Bar
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 134,
                              height: 4.5,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFrameToggleButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _enableFrame = !_enableFrame;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(
              _enableFrame ? Icons.fullscreen : Icons.phone_iphone,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              _enableFrame ? 'Layar Penuh' : 'Aktifkan Bingkai HP',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrameToggleFloatingButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        setState(() {
          _enableFrame = true;
        });
      },
      icon: const Icon(Icons.phone_iphone, size: 18),
      label: const Text('Bingkai HP', style: TextStyle(fontSize: 12)),
      backgroundColor: AppTheme.primaryNavy,
      foregroundColor: Colors.white,
    );
  }
}

class _StudioBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppTheme.primaryNavy.withValues(alpha: 0.35),
              const Color(0xFF0F172A).withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.7],
          ).createShader(
            Rect.fromCircle(center: center, radius: size.width * 0.45),
          );

    canvas.drawCircle(center, size.width * 0.45, glowPaint);

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.04);
    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
