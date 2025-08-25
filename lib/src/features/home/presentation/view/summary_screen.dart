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
import '../../../../services/service_locator.dart';
import '../../../../shared/constants/color_constants.dart';
import '../../../../shared/services/snackbar_service.dart';
import 'widgets/summary_content.dart';
import 'widgets/summary_shimmer.dart';
import 'widgets/summary_controls.dart';

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
    // final theme = Theme.of(context);
    return SafeArea(
      bottom: true,
      child: Scaffold(
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
              serviceLocator<SnackBarService>().showError(
                message: state.errorMessage!,
              );
            }
          },
          builder: (context, state) {
            if (state.isLoadingTranscription) {
              return const SummaryShimmer();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary container
                  SummaryContent(state: state, boundaryKey: pdfBoundaryKey),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
        ///todo: Uncomment when SummaryControls is implemented
        // bottomNavigationBar: BlocBuilder<SummariesBloc, SummariesState>(
        //   builder: (context, state) {
        //     return SafeArea(
        //       top: false,
        //       child: Container(
        //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        //         decoration: const BoxDecoration(color: Colors.white),
        //         child: LayoutBuilder(
        //           builder: (context, constraints) {
        //             final double iconMainSize = constraints.maxWidth < 360 ? 42 : 48;
        //             final double iconSubSize = constraints.maxWidth < 360 ? 36 : 40;
        //             final double buttonHeight = constraints.maxWidth < 360 ? 48 : 56;
        //
        //             final Widget timer = state.audioLoadStatus is StateLoading
        //                 ? Shimmer.fromColors(
        //                     baseColor: Colors.grey.shade300,
        //                     highlightColor: Colors.grey.shade100,
        //                     child: Container(
        //                       width: 180,
        //                       height: 22,
        //                       decoration: BoxDecoration(
        //                         color: Colors.white,
        //                         borderRadius: BorderRadius.circular(6),
        //                       ),
        //                     ),
        //                   )
        //                 : FittedBox(
        //                     child: _buildTimerText(state),
        //                   );
        //
        //             return SummaryControls(
        //               state: state,
        //               iconMainSize: iconMainSize,
        //               iconSubSize: iconSubSize,
        //               buttonHeight: buttonHeight,
        //               timer: timer,
        //               onShare: () async {
        //                 final bytes = await captureAsImage(pdfBoundaryKey);
        //                 if (context.mounted) {
        //                   context.read<SummariesBloc>().add(ShareSummary(imageBytes: bytes));
        //                 }
        //               },
        //               isShareLoading: state.shareSummaryStatus is StateLoading,
        //             );
        //           },
        //         ),
        //       ),
        //     );
        //   },
        // ),
      ),
    );
  }

  String _formatTime(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Widget _buildTimerText(SummariesState state) {
    final elapsed = _formatTime(state.currentPosition);
    final total = _formatTime(state.duration);
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        children: [
          TextSpan(text: elapsed, style: const TextStyle(color: ColorConst.orange)),
          const TextSpan(text: ' / '),
          TextSpan(text: total),
        ],
      ),
    );
  }


  Future<Uint8List> captureAsImage(GlobalKey key) async {
    final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}

