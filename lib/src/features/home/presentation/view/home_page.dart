import 'package:base_architecture/src/shared/constants/image_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_const.dart';
import '../../../../shared/constants/color_constants.dart';
import '../../../../shared/constants/string_constants.dart';
import '../../../../shared/constants/text_style_constants.dart';
import '../../../../shared/utilities/event_status.dart';
import '../../../../shared/utilities/responsive _constants.dart';

import '../../../../services/service_locator.dart';
import '../../../../shared/widgets/common_button.dart';
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
                Container(
                  width: rpHeight(context, 100),
                  height: rpHeight(context, 100),
                  decoration: const BoxDecoration(
                    color: ColorConst.lightGrey,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      ImageConst.noSummariesPlaceholder,
                      height: rpHeight(context, 60),
                      width: rpHeight(context, 60),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: rpHeight(context, 17)),
                // App name
                Text(
                  StringConst.noConsultationYet,
                  textAlign: TextAlign.center,
                  style: TextStyleConst.headlineSmallBold.copyWith(
                    color: ColorConst.black,
                    fontSize: rpHeight(context, 24),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: rpHeight(context, 8)),
                SizedBox(
                  width: rpWidth(context, 300),
                  child: Text(
                    StringConst.noSummariesDescription,
                    textAlign: TextAlign.center,
                    style: TextStyleConst.headlineSmallMedium.copyWith(
                      color: ColorConst.black,
                      fontSize: rpHeight(context, 12),
                    ),
                  ),
                ),
                SizedBox(height: rpHeight(context, 40)),
                CommonButton(
                  onTap: () {
                    context.pushNamed(
                      RouteConst.doctorsListingPage,
                      extra: {'selectionMode': true},
                    );
                  },
                  btnText: StringConst.continueWithApple,
                  backgroundColor: ColorConst.primaryBlue,
                  fontColor: ColorConst.white,
                  width: rpWidth(context, 351),
                  height: rpHeight(context, 56),
                  prefixIcon: Icon(
                    Icons.mic,
                    size: rpHeight(context, 24),
                    color: ColorConst.white,
                  ),
                  fontSize: rpHeight(context, 16),
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
