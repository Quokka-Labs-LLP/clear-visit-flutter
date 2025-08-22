import 'package:base_architecture/src/app/router/route_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../services/service_locator.dart';
import '../../../../shared/constants/color_constants.dart';
import '../../../../shared/constants/image_constants.dart';
import '../../../../shared/services/snackbar_service.dart';
import '../../../../shared/utilities/event_status.dart';
import '../bloc/auth_bloc.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final FocusNode _mobileFocusNode = FocusNode();

  @override
  void dispose() {
    _mobileController.dispose();
    _mobileFocusNode.dispose();
    super.dispose();
  }

  void _onContinueWithApple() {
    serviceLocator<SnackBarService>().showInfo(
      message: 'Coming Soon!',
      duration: const Duration(seconds: 2),
    );
  }

  void _onContinueWithGoogle() {
    context.read<AuthBloc>().add(OnGoogleSignInEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
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
                if (state.appleSignInStatus is StateLoading || state.googleSignInStatus is StateLoading)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black12.withOpacity(0.3),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: ColorConst.black,
                      ),
                    ),
                  )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(AuthState state) {
    return Column(
      children: [
        // Top section with logo and welcome text
        Flexible(
          flex: 2,
          child: _buildHeader(),
        ),
        // Authentication options section
        Flexible(
          flex: 3,
          child: _buildAuthenticationOptions(state),
        ),
        // Footer section - will be pushed to bottom
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo positioned at 30% from top
          SizedBox(height: MediaQuery.of(context).size.height * 0.08),
          Image.asset(
            ImageConst.splashName,
            height: 80,
            width: 80,
          ),
          const SizedBox(height: 24),
          // Welcome text
          Text(
            'Medical Conversations Made Simple',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Subtext
          Text(
            'AI-powered notes for your doctor visits',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF757575),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticationOptions(AuthState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (Platform.isIOS) ...[
            _buildAppleButton(state),
            const SizedBox(height: 16),
            _buildGoogleButton(state),
          ] else if (Platform.isAndroid) ...[
            _buildGoogleButton(state),
          ] else ...[
            _buildGoogleButton(state),
          ],
        ],
      ),
    );
  }

  Widget _buildAppleButton(AuthState state) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLoading = state.appleSignInStatus is StateLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _onContinueWithApple,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? Colors.white : Colors.black,
          foregroundColor: isDarkMode ? Colors.black : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDarkMode ? Colors.black : Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.apple,
                    size: 24,
                    color: isDarkMode ? Colors.black : Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Continue with Apple',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SF Pro Display',
                      color: isDarkMode ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGoogleButton(AuthState state) {
    final isLoading = state.googleSignInStatus is StateLoading;
    
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFDADCE0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: isLoading ? null : _onContinueWithGoogle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.black87),
                    ),
                  )
                else ...[
                  SvgPicture.asset(
                    ImageConst.googleIcon,
                    height: 24,
                    width: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Continue with Google',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Roboto',
                      color: Colors.black87,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF757575),
            height: 1.4,
          ),
          children: [
            const TextSpan(text: 'By continuing, you agree to our '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                color: ColorConst.primaryBlue,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(
                color: ColorConst.primaryBlue,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}