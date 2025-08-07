import 'package:base_architecture/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_const.dart';
import '../../../../shared/constants/color_constants.dart';
import '../../../../shared/utilities/event_status.dart';
import '../../../../shared/widgets/common_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared_pref_services/shared_pref_base_service.dart';
import '../../../../shared_pref_services/shared_pref_keys.dart';
import '../../../../services/service_locator.dart';
import '../bloc/home_bloc.dart';
import 'add_doctor_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _specializationFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();

  @override
  void dispose() {
    _doctorNameController.dispose();
    _specializationController.dispose();
    _locationController.dispose();
    _nameFocusNode.dispose();
    _specializationFocusNode.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<HomeBloc>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Previous Recordings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [

            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(OnLogout());
                context.goNamed(RouteConst.splashScreen);
                // Implement filter functionality
              },
            ),
          ],
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 10, // Dummy data count
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD), // Very light blue
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. John',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.pushNamed(RouteConst.addDoctorPage);
          },
          backgroundColor: ColorConst.primaryBlue,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
} 