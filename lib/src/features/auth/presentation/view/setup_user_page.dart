import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_const.dart';
import '../../../../services/service_locator.dart';
import '../../../../shared/utilities/event_status.dart';
import '../../../../shared/utilities/responsive _constants.dart';
import '../../../../shared/widgets/common_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared_pref_services/shared_pref_base_service.dart';
import '../../../../shared_pref_services/shared_pref_keys.dart';
import '../bloc/auth_bloc.dart';
import '../../../../shared/utilities/common_snackbar.dart';

class SetupUserPage extends StatefulWidget {
  const SetupUserPage({super.key});

  @override
  State<SetupUserPage> createState() => _SetupUserPageState();
}

class _SetupUserPageState extends State<SetupUserPage> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNameFromSharedPref();
  }

  Future<void> _loadNameFromSharedPref() async {
    final sharedPref = serviceLocator<SharedPreferenceBaseService>();
    final savedName = await sharedPref.getAttribute(SharedPrefKeys.name, '');
    if (savedName != null && savedName is String) {
      _nameController.text = savedName;
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }
    context.read<AuthBloc>().add(OnNameSubmitted(name: name));
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state.setNameStatus is StateLoaded) {
                  // Show success snackbar and navigate to home page
                  SnackBarHelper.showSuccessSnackBar(
                    context: context,
                    message: (state.setNameStatus as StateLoaded).successMessage ?? 'Name updated successfully',
                  );
                  Future.delayed(const Duration(milliseconds: 500), () {
                    context.goNamed(RouteConst.homePage);
                  });
                } else if (state.setNameStatus is StateFailed) {
                  // Show error snackbar
                  SnackBarHelper.showSuccessSnackBar(
                    context: context,
                    message: (state.setNameStatus as StateFailed).errorMessage,
                  );
                }
              },
              child: Stack(
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
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state.setNameStatus is StateLoading) {
                        return Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
