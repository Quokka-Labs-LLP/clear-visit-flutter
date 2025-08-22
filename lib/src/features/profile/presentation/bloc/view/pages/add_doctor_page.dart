import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../app/router/route_const.dart';
import '../../../../../../shared/constants/color_constants.dart';
import '../../../../../../shared/widgets/common_button.dart';
import '../../../../../../shared/widgets/custom_text_field.dart';
import '../../../../../../shared/utilities/event_status.dart';
import '../../../../../../services/service_locator.dart';
import '../../../../../../shared/services/snackbar_service.dart';
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
  
  // Validation error states
  String? _nameError;
  String? _specializationError;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    if (widget.doctor != null) {
      _isUpdateMode = true;
      _doctorNameController.text = widget.doctor!.name;
      _specializationController.text = widget.doctor!.specialization;
      _locationController.text = widget.doctor!.location ?? '';
    }
    
    // Add listeners for real-time validation
    _doctorNameController.addListener(_validateName);
    _specializationController.addListener(_validateSpecialization);
    _locationController.addListener(_validateLocation);
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

  // Validation methods
  void _validateName() {
    final name = _doctorNameController.text.trim();
    setState(() {
      if (name.isEmpty) {
        _nameError = 'Doctor name is required';
      } else if (name.length < 2) {
        _nameError = 'Doctor name must be at least 2 characters';
      } else if (name.length > 50) {
        _nameError = 'Doctor name cannot exceed 50 characters';
      } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
        _nameError = 'Doctor name can only contain letters and spaces';
      } else {
        _nameError = null;
      }
    });
  }

  void _validateSpecialization() {
    final specialization = _specializationController.text.trim();
    setState(() {
      if (specialization.isEmpty) {
        _specializationError = 'Specialization is required';
      } else if (specialization.length < 3) {
        _specializationError = 'Specialization must be at least 3 characters';
      } else if (specialization.length > 100) {
        _specializationError = 'Specialization cannot exceed 100 characters';
      } else if (!RegExp(r'^[a-zA-Z\s\-]+$').hasMatch(specialization)) {
        _specializationError = 'Specialization can only contain letters, spaces, and hyphens';
      } else {
        _specializationError = null;
      }
    });
  }

  void _validateLocation() {
    final location = _locationController.text.trim();
    setState(() {
      if (location.isNotEmpty) {
        if (location.length < 2) {
          _locationError = 'Location must be at least 2 characters';
        } else if (location.length > 100) {
          _locationError = 'Location cannot exceed 100 characters';
        } else if (!RegExp(r'^[a-zA-Z0-9\s\-,.]+$').hasMatch(location)) {
          _locationError = 'Location can only contain letters, numbers, spaces, commas, hyphens, and periods';
        } else {
          _locationError = null;
        }
      } else {
        _locationError = null; // Location is optional
      }
    });
  }

  bool _isFormValid() {
    return _nameError == null && 
           _specializationError == null && 
           _locationError == null &&
           _doctorNameController.text.trim().isNotEmpty &&
           _specializationController.text.trim().isNotEmpty;
  }

  void _addOrUpdateDoctor() {
    // Clear previous errors
    _validateName();
    _validateSpecialization();
    _validateLocation();

    // Check if form is valid
    if (!_isFormValid()) {
      serviceLocator<SnackBarService>().showWarning(
        message: 'Please fix the validation errors before submitting',
      );
      return;
    }

    final doctorName = _doctorNameController.text.trim();
    final specialization = _specializationController.text.trim();
    final location = _locationController.text.trim();

    if (_isUpdateMode && widget.doctor != null) {
      final updatedDoctor = widget.doctor!.copyWith(
        name: doctorName,
        specialization: specialization,
        location: location.isEmpty ? null : location,
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
    // Clear validation errors
    setState(() {
      _nameError = null;
      _specializationError = null;
      _locationError = null;
    });
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
              serviceLocator<SnackBarService>().showSuccess(
                message: _isUpdateMode 
                  ? 'Doctor updated successfully!' 
                  : 'Doctor added successfully!',
              );
              // Clear the status to prevent multiple snackbars
              context.read<ProfileBloc>().add(const ClearDoctorStatusEvent());
              context.pop(true);
            } else if (state.addDoctorStatus is StateFailed) {
              serviceLocator<SnackBarService>().showError(
                message: (state.addDoctorStatus as StateFailed).errorMessage,
              );
            }

            if (state.updateDoctorStatus is StateLoaded) {
              serviceLocator<SnackBarService>().showSuccess(
                message: 'Doctor updated successfully!',
              );
              // Clear the status to prevent multiple snackbars
              context.read<ProfileBloc>().add(const ClearDoctorStatusEvent());
              context.pop(true);
            } else if (state.updateDoctorStatus is StateFailed) {
              serviceLocator<SnackBarService>().showError(
                message: (state.updateDoctorStatus as StateFailed).errorMessage,
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
                errorText: _nameError,
                isEnabled: true,
                isReadOnly: false,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _specializationController,
                focusNode: _specializationFocusNode,
                hintText: "Specialization *",
                icon: Icons.medical_services,
                errorText: _specializationError,
                isEnabled: true,
                isReadOnly: false,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _locationController,
                focusNode: _locationFocusNode,
                hintText: "Location (Optional)",
                icon: Icons.location_on,
                errorText: _locationError,
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
                    onTap: isLoading || !_isFormValid() ? () {} : _addOrUpdateDoctor,
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