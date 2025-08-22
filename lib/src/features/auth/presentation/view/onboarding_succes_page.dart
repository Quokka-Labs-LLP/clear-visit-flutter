import 'package:base_architecture/src/shared/constants/color_constants.dart';
import 'package:base_architecture/src/shared/constants/image_constants.dart';
import 'package:base_architecture/src/shared/constants/string_constants.dart';
import 'package:base_architecture/src/shared/constants/text_style_constants.dart';
import 'package:base_architecture/src/shared/utilities/responsive _constants.dart';
import 'package:base_architecture/src/shared_pref_services/shared_pref_base_service.dart';
import 'package:base_architecture/src/shared_pref_services/shared_pref_keys.dart';
import 'package:base_architecture/src/services/service_locator.dart';
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

    // Set onboarding success in shared preferences
    _setOnboardingSuccess();

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

  void _setOnboardingSuccess() async {
    try {
      final sharedPrefService = serviceLocator<SharedPreferenceBaseService>();
      await sharedPrefService.setAttribute(SharedPrefKeys.isOnboarded, true);
    } catch (e) {
      // Handle error if needed
      debugPrint('Error setting onboarding success: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: rpWidth(context, 12)),
          child: Column(
            children: [
              SizedBox(height: rpHeight(context, 100)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        // Icon and text section
                        Column(
                          children: [
                            // Green circle background with Lottie animation
                            Container(
                              width: rpHeight(context, 100),
                              height: rpHeight(context, 100),
                              decoration: const BoxDecoration(
                                color: ColorConst.successGreen,
                                shape: BoxShape.circle,
                              ),
                              child: Lottie.asset(
                                ImageConst.successAnimation,
                                controller: _lottieController,
                                width: rpHeight(context, 60),
                                height: rpHeight(context, 60),
                                onLoaded: (composition) {
                                  // Ensure the controller duration matches the composition length scaled to 2 seconds
                                  // If composition duration differs, we animate to the end over controller's duration
                                  _lottieController
                                    ..reset()
                                    ..forward();
                                },
                              ),
                            ),
                            SizedBox(height: rpHeight(context, 17)),

                            // Text section
                            Column(
                              children: [
                                // Title fade-in at 500ms
                                AnimatedBuilder(
                                  animation: _titleOpacity,
                                  builder: (context, child) => Opacity(
                                    opacity: _titleOpacity.value,
                                    child: child,
                                  ),
                                  child: Text(
                                    StringConst.youreAllSet,
                                    textAlign: TextAlign.center,
                                    style: TextStyleConst.headlineSmallBold
                                        .copyWith(
                                          color: ColorConst.primaryBlue,
                                          fontSize: rpHeight(context, 24),
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                                SizedBox(height: rpHeight(context, 8)),

                                // Subtitle fade-in at 700ms
                                AnimatedBuilder(
                                  animation: _subtitleOpacity,
                                  builder: (context, child) => Opacity(
                                    opacity: _subtitleOpacity.value,
                                    child: child,
                                  ),
                                  child: Text(
                                    StringConst.medicalAiAssistantReady,
                                    textAlign: TextAlign.center,
                                    style: TextStyleConst.titleMedium.copyWith(
                                      color: ColorConst.greySubtitle,
                                      fontSize: rpHeight(context, 16),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: rpHeight(context, 40)),
                    Padding(
                      padding: EdgeInsets.only(bottom: rpHeight(context, 60)),
                      child: AnimatedBuilder(
                        animation: _buttonOpacity,
                        builder: (context, child) => Opacity(
                          opacity: _buttonOpacity.value,
                          child: child,
                        ),
                        child: Container(
                          width: double.infinity,
                          height: rpHeight(context, 56),
                          decoration: BoxDecoration(
                            color: ColorConst.primaryBlue,
                            borderRadius: BorderRadius.circular(
                              rpHeight(context, 50),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                rpHeight(context, 50),
                              ),
                              onTap: _onGetStarted,
                              child: Center(
                                child: Text(
                                  StringConst.getStarted,
                                  style: TextStyleConst.titleMedium.copyWith(
                                    color: ColorConst.white,
                                    fontSize: rpHeight(context, 16),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
