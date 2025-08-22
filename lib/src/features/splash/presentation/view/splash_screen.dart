import 'package:base_architecture/src/shared/constants/color_constants.dart';
import 'package:base_architecture/src/shared/constants/image_constants.dart';
import 'package:base_architecture/src/shared/constants/string_constants.dart';
import 'package:base_architecture/src/shared/constants/text_style_constants.dart';
import 'package:base_architecture/src/shared/utilities/responsive _constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_const.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  void _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.goNamed(RouteConst.start);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.primaryBlue,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: ColorConst.primaryBlue),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: rpWidth(context, 12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo container with circular background
                Container(
                  width: rpHeight(context, 100),
                  height: rpHeight(context, 100),
                  decoration: const BoxDecoration(
                    color: ColorConst.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      ImageConst.splashName,
                      height: rpHeight(context, 60),
                      width: rpHeight(context, 60),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: rpHeight(context, 17)),
                // App name
                Text(
                  StringConst.appName,
                  textAlign: TextAlign.center,
                  style: TextStyleConst.headlineSmallBold.copyWith(
                    color: ColorConst.white,
                    fontSize: rpHeight(context, 24),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: rpHeight(context, 8)),
                // Subtitle
                Text(
                  StringConst.appSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyleConst.bodySmall.copyWith(
                    color: ColorConst.white,
                    fontSize: rpHeight(context, 12),
                    fontWeight: FontWeight.w400,
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
