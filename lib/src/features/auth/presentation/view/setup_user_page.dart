import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../services/service_locator.dart';
import '../../../../shared/services/snackbar_service.dart';
import '../../../../shared/utilities/event_status.dart';
import '../../../../shared/widgets/common_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';

class SetupUserPage extends StatefulWidget {
  final bool isOnboarding;
  
  const SetupUserPage({super.key, this.isOnboarding = true});

  @override
  State<SetupUserPage> createState() => _SetupUserPageState();
}

class _SetupUserPageState extends State<SetupUserPage> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(GetUserName());
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      serviceLocator<SnackBarService>().showWarning(
        message: 'Please enter your name',
      );
      return;
    }
    context.read<AuthBloc>().add(OnNameSubmitted(name: name, fromSignUpPage: widget.isOnboarding));
  }

  @override
  void dispose() {
    _nameController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss keyboard on tap outside
      },
      child: Scaffold(
        // resizeToAvoidBottomInset: true,
        body: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state.name != null && state.name!.isNotEmpty) {
                _nameController.text = state.name!;
                debugPrint('Setting name in controller: ${state.name}');
              }
              if (state.setNameStatus is StateLoaded) {
                  context.pop(true);
                  state.setNameStatus = StateNotLoaded();

              } else if (state.setNameStatus is StateFailed) {
                serviceLocator<SnackBarService>().showError(
                  message: 'Something went wrong while setting your name',
                );
              }
            },
            builder: (context,state){
              return Stack(
                children: [
                  SafeArea(
                    child: SingleChildScrollView(
                      reverse: true,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        width: double.infinity,

                        child: Column(
                          children: [
                            // Top section with image and title
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 40),
                                // Placeholder network image
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 40),
                                // Beautiful title
                                const Text(
                                  "Set your name",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Help us personalize your experience",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 40),

                              ],
                            ),
                            // Bottom section with input and button
                            Column(
                              children: [
                                CustomTextField(
                                  controller: _nameController,
                                  focusNode: focusNode,
                                  hintText: "Enter your name",
                                  icon: Icons.person,
                                  errorText: null,
                                  isEnabled: true,
                                  isReadOnly: false,
                                  maxCharacters: 50,
                                ),
                                const SizedBox(height: 30),
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    return CommonButton(
                                      onTap: (){
                                        state.setNameStatus is StateLoading ? null : _handleSubmit();
                                      },
                                      btnText: state.setNameStatus is StateLoading ? "Updating..." : "Submit",
                                      fontSize: 16,
                                      fontColor: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Loading overlay
                  if (state.setNameStatus is StateLoading) Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
                  ),
                ],
              );
            }
        ),
      ),
    );
  }
}
