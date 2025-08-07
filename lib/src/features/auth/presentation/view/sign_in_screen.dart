import 'package:base_architecture/src/app/router/route_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;

import '../../../../app/router/router.dart';
import '../../../../shared/constants/color_constants.dart';
import '../../../../shared/constants/image_constants.dart';
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

  void _onMobileChanged(String value) {
    context.read<AuthBloc>().add(OnValidateMobileEvent(mobileNumber: value));
  }

  void _onSubmitPressed() {
    final bloc = context.read<AuthBloc>();
    if (bloc.state.isMobileValid) {
      bloc.add(
        bloc.state.isSignInMode
            ? OnMobileSignInEvent(mobileNumber: _mobileController.text)
            : OnSignUpEvent(mobileNumber: _mobileController.text),
      );
    }
  }

  void _toggleMode() {
    context.read<AuthBloc>().add(OnToggleAuthMode());
  }

  void _onContinueWithApple() {
    context.read<AuthBloc>().add(OnAppleSignInEvent());

  }

  void _onContinueWithGoogle() {
    context.read<AuthBloc>().add(OnGoogleSignInEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: ColorConst.white,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.signInStatus is StateLoaded) {
              context.goNamed(RouteConst.homePage);
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(state),
                      const SizedBox(height: 50),
                      _buildForm(state),
                      const SizedBox(height: 30),
                      _buildFooter(),
                    ],
                  ),
                ),
                if(state.signInStatus is StateLoading)
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

  Widget _buildHeader(AuthState state) {
    return Column(
      children: [
        Image.asset(ImageConst.splashName, height: 100),
        const SizedBox(height: 24),
        Text(
          state.isSignInMode ? 'Welcome Back' : 'Create Account',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: ColorConst.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.isSignInMode
              ? 'Sign in to clear you conversations'
              : 'Sign up to get started',
          style: const TextStyle(
            fontSize: 16,
            color: ColorConst.grey,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(AuthState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildPlatformButtons(),
        ],
      ),
    );
  }

  Widget _buildPlatformButtons() {
    if (Platform.isIOS) {
      // On iOS, show both Google and Apple buttons
      return Column(
        children: [
          _buildGoogleButton(),
          const SizedBox(height: 16),
          _buildAppleButton(),
        ],
      );
    } else if (Platform.isAndroid) {
      // On Android, show only Google button
      return _buildGoogleButton();
    } else {
      // Fallback for other platforms
      return Container();
    }
  }

  Widget _buildAppleButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _onContinueWithApple,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: const Icon(Icons.apple, size: 24),
        label: const Text(
          'Continue with Apple',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _onContinueWithGoogle,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        icon: const Icon(Icons.g_mobiledata, size: 24),
        label: const Text(
          'Continue with Google',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }



  Widget _buildSubmitButton(AuthState state) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: state.isMobileValid && state.apiCallStatus is! StateLoading
            ? _onSubmitPressed
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConst.primaryBlue,
          foregroundColor: ColorConst.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
        ),
        child: state.apiCallStatus is StateLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(ColorConst.white),
          ),
        )
            : Text(
          state.isSignInMode ? 'Sign In' : 'Sign Up',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildToggleModeText(AuthState state) {
    return GestureDetector(
      onTap: _toggleMode,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            state.isSignInMode ? 'Don\'t have an account? ' : 'Already have an account? ',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          Text(
            state.isSignInMode ? 'Sign Up' : 'Sign In',
            style: const TextStyle(
              color: ColorConst.primaryBlue,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Text(
        'By continuing, you agree to our Terms of Service\nand Privacy Policy',
        style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.4),
        textAlign: TextAlign.center,
      ),
    );
  }
}