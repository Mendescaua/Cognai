import 'dart:math' as math;
import 'dart:ui';
import 'package:cognai/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _reveal;
  late final Animation<double> _fadeIn;
  late final Animation<double> _float;

  final String _headline = 'cognai. converse. descubra. resolva.';
  final String _sub = 'Seu copiloto cognitivo — rápido, seguro e sempre ativo.';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _reveal = CurvedAnimation(parent: _ctrl, curve: const Interval(.15, .75, curve: Curves.easeOut));
    _fadeIn = CurvedAnimation(parent: _ctrl, curve: const Interval(.35, 1, curve: Curves.easeOut));
    _float  = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine);
    _ctrl.repeat(period: const Duration(seconds: 6), reverse: true);
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _ctrl.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cardW = math.min(size.width * 0.9, 520.0);
    final cardH = math.min(size.height * 0.52, 520.0);

    // Cores do tema
    final primary = Theme.of(context).colorScheme.primary;     // azul
    final secondary = Theme.of(context).colorScheme.secondary; // azul suave
    final bg = Theme.of(context).scaffoldBackgroundColor;      // cinza escuro
    final onSurface = Theme.of(context).colorScheme.onSurface; // texto

    // tons derivados para o gradiente de fundo
    final bg2 = Color.alphaBlend(Colors.black.withOpacity(.12), bg);
    final bg3 = Color.alphaBlend(Colors.black.withOpacity(.22), bg);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // --- BACKGROUND: cinza escuro + blobs azuis ---
          _DarkGradientBackground(c1: bg, c2: bg2, c3: bg3),
          _NeonBlob(top: -60, left: -40, size: 260, colors: [primary, secondary]),
          _NeonBlob(bottom: -40, right: -20, size: 220, colors: [secondary, primary]),
          _NeonBlob(top: size.height * .35, left: size.width * .6, size: 180, colors: [
            primary, Color.alphaBlend(Colors.black.withOpacity(.35), primary),
          ]),

          // --- CONTEÚDO ---
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // CARD central com glass + flutuação
                  AnimatedBuilder(
                    animation: _float,
                    builder: (_, __) {
                      final dy = math.sin(_ctrl.value * math.pi * 2) * 6;
                      return Transform.translate(
                        offset: Offset(0, dy),
                        child: Center(
                          child: _GlassCard(
                            width: cardW,
                            height: cardH,
                            borderColor: AppTheme.borderColor,
                            overlayA: primary,
                            overlayB: secondary,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Lottie.asset(
                                'assets/animation/Splash.json',
                                repeat: true,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 26),

                  // Headline com “efeito digitação”
                  AnimatedBuilder(
                    animation: _reveal,
                    builder: (_, __) {
                      final chars = (_headline.length * _reveal.value).clamp(0, _headline.length).floor();
                      final text = _headline.substring(0, chars);
                      return Text(
                        text.isEmpty ? ' ' : text,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: onSurface.withOpacity(.95),
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                              letterSpacing: .3,
                            ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  FadeTransition(
                    opacity: _fadeIn,
                    child: Text(
                      _sub,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.25,
                          ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),

          // --- CTA: botão circular com glow azul ---
          Positioned(
            right: 22,
            bottom: 28 + MediaQuery.of(context).padding.bottom,
            child: _GlowingCTA(
              onTap: () => Navigator.pushReplacementNamed(context, '/home'),
              primary: primary,
              secondary: secondary,
              icon: Icons.arrow_forward_rounded,
              fill: bg3,
              iconColor: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- Widgets de UI --------------------

class _DarkGradientBackground extends StatelessWidget {
  final Color c1, c2, c3;
  const _DarkGradientBackground({required this.c1, required this.c2, required this.c3});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1],
          colors: [c1, c2, c3],
        ),
      ),
    );
  }
}

class _NeonBlob extends StatelessWidget {
  final double? top, left, right, bottom;
  final double size;
  final List<Color> colors;
  const _NeonBlob({
    this.top, this.left, this.right, this.bottom,
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final blob = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            colors.first.withOpacity(.40),
            colors.last.withOpacity(.12),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
    );

    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 38, sigmaY: 38),
        child: blob,
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final double width, height;
  final Widget child;
  final Color borderColor;
  final Color overlayA;
  final Color overlayB;
  const _GlassCard({
    required this.width,
    required this.height,
    required this.child,
    required this.borderColor,
    required this.overlayA,
    required this.overlayB,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor.withOpacity(.5), width: 1.2),
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(.08),
            Colors.white.withOpacity(.03),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 60,
            spreadRadius: -20,
            offset: Offset(0, 28),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), child: const SizedBox()),
            child,
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [
                      overlayA.withOpacity(.10),
                      overlayB.withOpacity(.08),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowingCTA extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color primary;
  final Color secondary;
  final Color fill;
  final Color iconColor;
  const _GlowingCTA({
    required this.onTap,
    required this.icon,
    required this.primary,
    required this.secondary,
    required this.fill,
    required this.iconColor,
  });

  @override
  State<_GlowingCTA> createState() => _GlowingCTAState();
}

class _GlowingCTAState extends State<_GlowingCTA> with SingleTickerProviderStateMixin {
  late final AnimationController _a;
  @override
  void initState() {
    super.initState();
    _a = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, __) {
        final t = (math.sin(_a.value * math.pi * 2) + 1) / 2; // 0..1
        final glow = 12.0 + 22.0 * t;
        return Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [widget.primary, widget.secondary,
                Color.alphaBlend(Colors.black.withOpacity(.35), widget.primary),
                widget.primary],
            ),
            boxShadow: [
              BoxShadow(color: widget.primary.withOpacity(.45), blurRadius: glow, spreadRadius: 1),
            ],
          ),
          child: Material(
            color: widget.fill,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Icon(widget.icon, size: 28, color: widget.iconColor),
              ),
            ),
          ),
        );
      },
    );
  }
}
