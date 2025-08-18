import 'package:base_architecture/src/app/router/route_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../app/router/route_const.dart';
import '../../../../../../shared/utilities/event_status.dart';
import '../../../../data/model/doctor_model.dart';
import '../../profile_bloc.dart';
import '../widgets/empty_doctors_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/doctors_list_widget.dart';

class DoctorsListingPage extends StatefulWidget {
  final bool selectionMode;
  final bool isTrial;

  const DoctorsListingPage({super.key, this.selectionMode = false, this.isTrial = false});

  @override
  State<DoctorsListingPage> createState() => _DoctorsListingPageState();
}

class _DoctorsListingPageState extends State<DoctorsListingPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const FetchDoctorsEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<ProfileBloc>().state;
      if (state.hasMoreDoctors && !state.isLoadingMore && state.doctors.isNotEmpty) {
        context.read<ProfileBloc>().add(const FetchDoctorsEvent(isLoadMore: true));
      }
    }
  }

  void _navigateToAddDoctor({DoctorModel? doctor}) async {
    final result = await context.pushNamed<bool>(RouteConst.addDoctorPage, extra: doctor);
    
    // If result is true, refresh the doctors list
    if (result == true) {
      context.read<ProfileBloc>().add(const FetchDoctorsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectionMode ? 'Select Doctor' : 'My Doctors'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(RouteConst.homePage);
            }
          },
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.fetchDoctorListStatus is StateFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  (state.fetchDoctorListStatus as StateFailed).errorMessage,
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.fetchDoctorListStatus is StateLoading && state.doctors.isEmpty) {
            return const LoadingWidget();
          }

          if (state.doctors.isEmpty && state.fetchDoctorListStatus is StateLoaded) {
            return const EmptyDoctorsWidget();
          }

          return DoctorsListWidget(
            scrollController: _scrollController,
            onRefresh: () async {
              context.read<ProfileBloc>().add(const FetchDoctorsEvent());
            },
            onDoctorTap: (doctor) {
              if (widget.selectionMode) {
                context.pushNamed(RouteConst.recordingScreen, extra: RecordingScreenArgs(
                  doctorId: doctor.id,
                  doctorName: doctor.name,
                  isTrial: widget.isTrial,
                ));
              } else {
                _navigateToAddDoctor(doctor: doctor);
              }
            },
            onDoctorEditTap: (doctor) => _navigateToAddDoctor(doctor: doctor),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.pushNamed<bool>(RouteConst.addDoctorPage);
          if (result == true) {
              if (mounted) {
                context.read<ProfileBloc>().add(const FetchDoctorsEvent());
              }
          }
        },
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: Icon(widget.selectionMode ? Icons.person_add : Icons.add),
      ),
    );
  }


}
