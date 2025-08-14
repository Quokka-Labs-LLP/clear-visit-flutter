import 'dart:typed_data';

import 'package:base_architecture/src/app/router/route_const.dart';
import 'package:base_architecture/src/features/home/presentation/bloc/summaries_bloc.dart';
import 'package:base_architecture/src/shared/utilities/event_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui' as ui;

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final extras = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final filePath = extras?['filePath'] as String?;
    final doctorId = extras?['doctorId'] as String?;
    final doctorName = extras?['doctorName'] as String?;
    final summaryId = extras?['summaryId'] as String?;
    if (summaryId == null) {
      return BlocProvider(
        create: (_) => SummariesBloc()
          ..add(
            StartTranscriptionEvent(
              localFilePath: filePath,
              doctorId: doctorId,
              doctorName: doctorName,
            ),
          )
          ..add(LoadAudioEvent(localPath: filePath)),
        child: _SummaryBody(),
      );
    } else {
      return BlocProvider(
        create: (_) => SummariesBloc()..add(GetSummaryDetailsEvent(summaryId)),
        child: _SummaryBody(),
      );
    }
  }
}

class _SummaryBody extends StatelessWidget {
  _SummaryBody();

  final GlobalKey pdfBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(RouteConst.homePage),
        ),
        title: const Text('Summary'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<SummariesBloc, SummariesState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.isLoadingTranscription) {
            return _SummaryShimmer();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary container
                RepaintBoundary(
                  key: pdfBoundaryKey,
                  child: Container(
                    color: Colors.white, // ✅ White background for PDF
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Doctor name
                        Text(
                          state.summaryModel?.doctorName == null
                              ? "Doctor"
                              : "Dr. ${state.summaryModel?.doctorName}", // Make sure this is in your state
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Date & Time
                        Text(
                          _formatFullDateTime(
                            DateTime.now(),
                          ), // You can use summary date if available
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Summary title
                        const Text(
                          'Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Summary text
                        Text(
                          state.summaryModel?.summaryText ??
                              'No summary available',
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 24),

                        // Follow-up questions
                        if (state.summaryModel?.followUpQuestions?.isNotEmpty ??
                            false) ...[
                          const Text(
                            'Follow-up Questions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...state.summaryModel!.followUpQuestions!.map(
                            (q) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '• ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      q,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),
                Column(
                  children: [
                    // Timer with shimmer while loading audio
                    if (state.audioLoadStatus is StateLoading)
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 160,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      )
                    else
                      Text(
                        "${_formatTime(state.currentPosition)} / ${_formatTime(state.duration)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Animated Play/Pause + Stop with download progress overlay
                    if (state.audioLoadStatus is StateLoading)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_arrow, size: 50, color: Colors.grey),
                            onPressed: null,
                          ),
                          SizedBox(
                            height: 56,
                            width: 56,
                            child: CircularProgressIndicator(
                              value: state.audioDownloadProgress > 0 ? state.audioDownloadProgress : null,
                              strokeWidth: 4,
                            ),
                          ),
                        ],
                      )
                    else
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: state.isPlaying
                            ? Row(
                                key: const ValueKey('pauseStop'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.pause, size: 40),
                                    onPressed: () => context
                                        .read<SummariesBloc>()
                                        .add(PauseAudioEvent()),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(Icons.stop, size: 40),
                                    onPressed: () => context
                                        .read<SummariesBloc>()
                                        .add(StopAudioEvent()),
                                  ),
                                ],
                              )
                            : IconButton(
                                key: const ValueKey('play'),
                                icon: const Icon(Icons.play_arrow, size: 50),
                                onPressed: () => context
                                    .read<SummariesBloc>()
                                    .add(PlayAudioEvent()),
                              ),
                      ),

                    const SizedBox(height: 20),

                    // Share button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final bytes = await captureAsImage(pdfBoundaryKey);
                          context.read<SummariesBloc>().add(
                            ShareSummary(imageBytes: bytes),
                          );
                        },
                        child: state.shareSummaryStatus is StateLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Share",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTime(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  String _formatFullDateTime(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}/"
        "${dateTime.month.toString().padLeft(2, '0')}/"
        "${dateTime.year}  "
        "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Future<Uint8List> captureAsImage(GlobalKey key) async {
    final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}

class _SummaryShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
