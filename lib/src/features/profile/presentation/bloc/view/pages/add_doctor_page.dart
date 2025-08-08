import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../app/router/route_const.dart';
import '../../../../../../shared/constants/color_constants.dart';
import '../../../../../../shared/widgets/common_button.dart';
import '../../../../../../shared/widgets/custom_text_field.dart';
import '../../../../../../shared/utilities/event_status.dart';
import '../../../../../../services/service_locator.dart';
import '../../../../data/model/doctor_model.dart';
import '../../profile_bloc.dart';

class AddDoctorPage extends StatefulWidget {
  final DoctorModel? doctor;
  
  const AddDoctorPage({super.key, this.doctor});

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
  bool _isUpdateMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.doctor != null) {
      _isUpdateMode = true;
      _doctorNameController.text = widget.doctor!.name;
      _specializationController.text = widget.doctor!.specialization;
      _locationController.text = widget.doctor!.location ?? '';
    }
  }

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

  void _addOrUpdateDoctor() {
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

    if (_isUpdateMode && widget.doctor != null) {
      final updatedDoctor = widget.doctor!.copyWith(
        name: doctorName,
        specialization: specialization,
        location: location.isNotEmpty ? location : null,
      );
      context.read<ProfileBloc>().add(UpdateDoctorEvent(doctor: updatedDoctor));
    } else {
      context.read<ProfileBloc>().add(
        AddDoctorEvent(
          name: doctorName,
          specialization: specialization,
          location: location,
        ),
      );
    }
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
        title: Text(_isUpdateMode ? 'Update Doctor' : 'Add a Doctor'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state.addDoctorStatus is StateLoaded) {
              if (!_isUpdateMode) {
                _clearForm();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isUpdateMode 
                    ? 'Doctor updated successfully!' 
                    : 'Doctor added successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Clear the status to prevent multiple snackbars
              context.read<ProfileBloc>().add(const ClearDoctorStatusEvent());
              context.pop(true);
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

            if (state.updateDoctorStatus is StateLoaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Doctor updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Clear the status to prevent multiple snackbars
              context.read<ProfileBloc>().add(const ClearDoctorStatusEvent());
              context.pop(true);
            } else if (state.updateDoctorStatus is StateFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    (state.updateDoctorStatus as StateFailed).errorMessage,
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
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  final isLoading = state.addDoctorStatus is StateLoading || 
                                 state.updateDoctorStatus is StateLoading;
                  final buttonText = isLoading 
                    ? (_isUpdateMode ? "Updating..." : "Adding...") 
                    : (_isUpdateMode ? "Update Doctor" : "Add Doctor");
                  
                  return CommonButton(
                    onTap:() { isLoading ? null : _addOrUpdateDoctor();},
                    btnText: buttonText,
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