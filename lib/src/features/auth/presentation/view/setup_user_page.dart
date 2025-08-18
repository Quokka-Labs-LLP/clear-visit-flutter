import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_const.dart';
import '../../../../shared/utilities/event_status.dart';
import '../../../../shared/utilities/responsive _constants.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
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
    return Scaffold(
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Something went wrong while setting your name'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context,state){
            return Stack(
              children: [
                SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                        const SizedBox(height: 30),
                        const Text(
                          "Set your name",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: rpHeight(context, 50)),
                        CustomTextField(
                          controller: _nameController,
                          focusNode: focusNode,
                          hintText: "Enter your name",
                          icon: Icons.person,
                          errorText: null,
                          isEnabled: true,
                          isReadOnly: false,
                        ),
                        const SizedBox(height: 50),
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
                  ),
                ),
                // Loading overlay
                if (state.setNameStatus is StateLoading) Container(
                  color: Colors.black.withOpacity(0.3),
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
    );
  }
}
