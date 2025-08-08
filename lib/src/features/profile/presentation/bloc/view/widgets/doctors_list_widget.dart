import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/model/doctor_model.dart';
import '../../profile_bloc.dart';
import 'doctor_card.dart';
import 'pagination_loader.dart';

class DoctorsListWidget extends StatelessWidget {
  final ScrollController scrollController;
  final VoidCallback onRefresh;
  final Function(DoctorModel) onDoctorTap;
  final Function(DoctorModel) onDoctorEditTap;

  const DoctorsListWidget({
    super.key,
    required this.scrollController,
    required this.onRefresh,
    required this.onDoctorTap,
    required this.onDoctorEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh:(){
            onRefresh();
            return Future.value();
          } ,
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.doctors.length + 1, // +1 for pagination loader
            itemBuilder: (context, index) {
              if (index == state.doctors.length) {
                return PaginationLoader(
                  isLoading: state.isLoadingMore,
                  hasMoreItems: state.hasMoreDoctors,
                  hasReachedEnd: state.hasReachedEnd,
                );
              }

              final doctor = state.doctors[index];
              return DoctorCard(
                doctor: doctor,
                onTap: () => onDoctorTap(doctor),
                onEditTap: () => onDoctorEditTap(doctor),
              );
            },
          ),
        );
      },
    );
  }
}
