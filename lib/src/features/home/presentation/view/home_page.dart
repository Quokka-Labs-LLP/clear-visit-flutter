import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_const.dart';
import '../../../../shared/utilities/event_status.dart';
import '../../../../shared/utilities/responsive _constants.dart';

import '../../../../services/service_locator.dart';
import '../bloc/summaries_bloc.dart';
import '../bloc/trial/trial_bloc.dart';
import 'widgets/practice_trial_banner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SummariesBloc()..add(const FetchSummariesEvent()),
        ),
        BlocProvider(
          create: (_) => TrialBloc()..add(const CheckTrialEligibility()),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Summaries',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                context.pushNamed(RouteConst.profileScreen);
              },
            ),
          ],
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            // Trial Banner
            BlocBuilder<TrialBloc, TrialState>(
              builder: (context, trialState) {
                if (trialState.isEligible) {
                  return const SizedBox.shrink();

                  return const PracticeTrialBanner();
                }
                return const SizedBox.shrink();
              },
            ),
            // Summaries List
            Expanded(child: _SummariesList()),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: FloatingActionButton(
            onPressed: () {
              context.pushNamed(RouteConst.doctorsListingPage, extra: {'selectionMode': true});
            },
            backgroundColor: Colors.black,
            child: const Icon(Icons.mic, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _SummariesList extends StatefulWidget {
  @override
  State<_SummariesList> createState() => _SummariesListState();
}

class _SummariesListState extends State<_SummariesList> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) return;
    final state = context.read<SummariesBloc>().state;
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 200) {
      if (state.hasMore &&
          !state.isLoadingMore &&
          state.summariesWithDoctorNames.isNotEmpty) {
        context.read<SummariesBloc>().add(
          const FetchSummariesEvent(isLoadMore: true),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SummariesBloc, SummariesState>(
      builder: (context, state) {
        if (state.fetchStatus is StateLoading &&
            state.summariesWithDoctorNames.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.summariesWithDoctorNames.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.note_alt_outlined,
                  size: 72,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                const Text(
                  'No summaries yet',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Trigger a fresh fetch of summaries
            context.read<SummariesBloc>().add(const FetchSummariesEvent());
          },
          child: ListView.builder(
            controller: _controller,
            padding: const EdgeInsets.all(16),
            itemCount: state.summariesWithDoctorNames.length + 1,
            itemBuilder: (context, index) {
              if (index == state.summariesWithDoctorNames.length) {
                if (state.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state.hasReachedEnd) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'You reached the end of the list',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }

              final summaryWithDoctor = state.summariesWithDoctorNames[index];
              return InkWell(
                onTap: () {
                  final id = summaryWithDoctor.summary.id;
                  if (id != null) {
                    context.pushNamed(
                      RouteConst.summaryScreen,
                      extra: {'summaryId': id},
                    );
                    // context.pushNamed(RouteConst.summaryDetailScreen, extra: id);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Dr. ${summaryWithDoctor.doctorName}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (summaryWithDoctor.summary.summaryText != null)
                        Text(
                          summaryWithDoctor.summary.summaryText!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
