import 'package:base_architecture/src/shared/constants/color_constants.dart';
import 'package:base_architecture/src/shared/constants/image_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../app/router/route_const.dart';

class OnboardingSuccessPage extends StatefulWidget {
  const OnboardingSuccessPage({super.key});

  @override
  State<OnboardingSuccessPage> createState() => _OnboardingSuccessPageState();
}

class _OnboardingSuccessPageState extends State<OnboardingSuccessPage>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _subtitleOpacity;
  late final Animation<double> _buttonOpacity;

  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();

    // Lottie controller for 2-second animation
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    // Fade controller for staggered fade-ins
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _titleOpacity = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    );

    _subtitleOpacity = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    );

    _buttonOpacity = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.9, 1.0, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  void _onGetStarted() {
    context.goNamed(RouteConst.homePage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Checkmark Lottie animation (2 seconds)
                SizedBox(
                  height: 160,
                  width: 160,
                  child: Lottie.asset(
                    ImageConst.successAnimation,
                    controller: _lottieController,
                    onLoaded: (composition) {
                      // Ensure the controller duration matches the composition length scaled to 2 seconds
                      // If composition duration differs, we animate to the end over controller's duration
                      _lottieController
                        ..reset()
                        ..forward();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Title fade-in at 500ms
                AnimatedBuilder(
                  animation: _titleOpacity,
                  builder: (context, child) => Opacity(
                    opacity: _titleOpacity.value,
                    child: child,
                  ),
                  child: const Text(
                    "You're all set!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorConst.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle fade-in at 700ms
                AnimatedBuilder(
                  animation: _subtitleOpacity,
                  builder: (context, child) => Opacity(
                    opacity: _subtitleOpacity.value,
                    child: child,
                  ),
                  child: const Text(
                    'Your medical conversation assistant is ready',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Button fade-in at 900ms
                Spacer(),
                AnimatedBuilder(
                  animation: _buttonOpacity,
                  builder: (context, child) => Opacity(
                    opacity: _buttonOpacity.value,
                    child: child,
                  ),
                  child: SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConst.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _onGetStarted,
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

