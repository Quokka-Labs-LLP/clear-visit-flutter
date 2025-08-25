import 'package:base_architecture/src/app/router/route_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../services/service_locator.dart';
import '../../../../shared/constants/color_constants.dart';
import '../../../../shared/constants/image_constants.dart';
import '../../../../shared/constants/string_constants.dart';
import '../../../../shared/constants/text_style_constants.dart';
import '../../../../shared/services/snackbar_service.dart';
import '../../../../shared/utilities/event_status.dart';
import '../../../../shared/utilities/responsive _constants.dart';
import '../../../../shared/widgets/common_button.dart';
import '../bloc/auth_bloc.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  void _onContinueWithApple() {
    serviceLocator<SnackBarService>().showInfo(
      message: StringConst.comingSoon,
      duration: const Duration(seconds: 2),
    );
  }

  void _onContinueWithGoogle() {
    context.read<AuthBloc>().add(OnGoogleSignInEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.white,
      body: SafeArea(
        bottom: true,
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.googleSignInStatus is StateLoaded) {
              // If new signup (missing names previously), go onboarding success, else home
              if (state.isNewSignup) {
                context.goNamed(RouteConst.onboardingSuccess);
              } else {
                context.goNamed(RouteConst.homePage);
              }
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                _buildMainContent(state),
                if (state.appleSignInStatus is StateLoading ||
                    state.googleSignInStatus is StateLoading)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: ColorConst.black.withOpacity(0.3),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: ColorConst.primaryBlue,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(AuthState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rpWidth(context, 16)),
      child: Column(
        children: [
          // Header with logo and text - takes most of the space
          Expanded(child: _buildHeader()),
          // Authentication buttons
          _buildAuthenticationOptions(state),
          // Footer - fixed at bottom
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo - circular container with subtle background
        Container(
          height: rpHeight(context, 100),
          width: rpHeight(context, 100),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorConst.white,
          ),
          child: Center(
            child: Image.asset(
              ImageConst.splashName,
              height: rpHeight(context, 80),
              width: rpHeight(context, 80),
            ),
          ),
        ),
        SizedBox(height: rpHeight(context, 16)),
        // App Name
        Text(
          StringConst.appName,
          style: TextStyleConst.headlineLargeBold.copyWith(
            fontSize: rpHeight(context, 32),
            color: ColorConst.black,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: rpHeight(context, 8)),
        // Main title
        Text(
          StringConst.appTitle,
          style: TextStyleConst.titleMedium.copyWith(
            fontSize: rpHeight(context, 16),
            color: ColorConst.black,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: rpHeight(context, 4)),
        // Subtitle
        Text(
          StringConst.appSubtitle,
          style: TextStyleConst.bodyLarge.copyWith(
            fontSize: rpHeight(context, 12),
            color: ColorConst.grey60,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthenticationOptions(AuthState state) {
    return Column(
      children: [
        if (Platform.isIOS) ...[
          _buildAppleButton(state),
          SizedBox(height: rpHeight(context, 12)),
          _buildGoogleButton(state),
        ] else if (Platform.isAndroid) ...[
          _buildGoogleButton(state),
        ] else ...[
          _buildGoogleButton(state),
        ],
        SizedBox(height: rpHeight(context, 70)),
      ],
    );
  }

  Widget _buildAppleButton(AuthState state) {
    final isLoading = state.appleSignInStatus is StateLoading;

    return CommonButton(
      onTap: _onContinueWithApple,
      btnText: StringConst.continueWithApple,
      backgroundColor: ColorConst.black,
      fontColor: ColorConst.white,
      isLoading: isLoading,
      height: rpHeight(context, 56),
      prefixIcon: Icon(
        Icons.apple,
        size: rpHeight(context, 24),
        color: ColorConst.white,
      ),
      fontSize: rpHeight(context, 16),
    );
  }

  Widget _buildGoogleButton(AuthState state) {
    final isLoading = state.googleSignInStatus is StateLoading;

    return CommonButton(
      onTap: _onContinueWithGoogle,
      btnText: StringConst.continueWithGoogle,
      backgroundColor: ColorConst.white,
      fontColor: ColorConst.black,
      borderColor: const Color(0xFFDADCE0),
      height: rpHeight(context, 56),
      prefixIcon: SvgPicture.asset(
        ImageConst.googleIcon,
        height: rpHeight(context, 24),
        width: rpHeight(context, 24),
      ),
      fontSize: rpHeight(context, 16),
    );
  }
}
