import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/color_constants.dart';
import '../../../../shared/widgets/common_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/utilities/event_status.dart';
import '../../../../services/service_locator.dart';
import '../bloc/home_bloc.dart';

class AddDoctorPage extends StatefulWidget {
  const AddDoctorPage({super.key});

  @override
  State<AddDoctorPage> createState() => _AddDoctorPageState();
}

class _AddDoctorPageState extends State<AddDoctorPage> {
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

  void _addDoctor() {
    final doctorName = _doctorNameController.text.trim();
    final specialization = _specializationController.text.trim();
    final location = _locationController.text.trim();

    if (doctorName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter doctor name')),
      );
      return;
    }

    if (specialization.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter specialization')),
      );
      return;
    }

    context.read<HomeBloc>().add(
      OnAddDoctorEvent(
        name: doctorName,
        specialization: specialization,
        location: location,
      ),
    );
  }

  void _clearForm() {
    _doctorNameController.clear();
    _specializationController.clear();
    _locationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text('Add a Doctor'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state.addDoctorStatus is StateLoaded) {
              _clearForm();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Doctor added successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state.addDoctorStatus is StateFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    (state.addDoctorStatus as StateFailed).errorMessage,
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _doctorNameController,
                focusNode: _nameFocusNode,
                hintText: "Doctor Name *",
                icon: Icons.person,
                errorText: null,
                isEnabled: true,
                isReadOnly: false,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _specializationController,
                focusNode: _specializationFocusNode,
                hintText: "Specialization *",
                icon: Icons.medical_services,
                errorText: null,
                isEnabled: true,
                isReadOnly: false,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _locationController,
                focusNode: _locationFocusNode,
                hintText: "Location (Optional)",
                icon: Icons.location_on,
                errorText: null,
                isEnabled: true,
                isReadOnly: false,
              ),
              const SizedBox(height: 30),
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  return CommonButton(
                    onTap: (){
                      state.addDoctorStatus is StateLoading ? null : _addDoctor();
                    },
                    btnText: state.addDoctorStatus is StateLoading ? "Adding..." : "Add Doctor",
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
    );
  }
}