import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:base_architecture/src/features/home/presentation/bloc/summaries_bloc.dart';
import 'package:base_architecture/src/shared/utilities/event_status.dart';

import '../../../../../shared/constants/color_constants.dart';

class SummaryControls extends StatelessWidget {
  final SummariesState state;
  final double iconMainSize;
  final double iconSubSize;
  final double buttonHeight;
  final Widget timer;
  final VoidCallback onShare;
  final bool isShareLoading;

  const SummaryControls({
    super.key,
    required this.state,
    required this.iconMainSize,
    required this.iconSubSize,
    required this.buttonHeight,
    required this.timer,
    required this.onShare,
    required this.isShareLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        timer,
        const SizedBox(height: 16),
        // Controls row has fixed height to prevent timer jump
        SizedBox(
          height: iconMainSize, // ensure stable height
          child: Center(
            child: _buildControls(context),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onShare,
            child: isShareLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    "Share",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context) {
    if (state.audioLoadStatus is StateLoading) {
      return SizedBox(
        height: iconMainSize,
        width: iconMainSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: iconMainSize + 6,
              width: iconMainSize + 6,
              child: CircularProgressIndicator(
                value: state.audioDownloadProgress > 0 ? state.audioDownloadProgress : null,
                strokeWidth: 4,
              ),
            ),
            Icon(Icons.play_arrow, size: iconMainSize, color: Colors.grey),
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: state.isPlaying
          ? Row(
              key: const ValueKey('pauseStop'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: iconSubSize,
                  icon: const Icon(Icons.pause, color: ColorConst.orange),
                  onPressed: () => context.read<SummariesBloc>().add(PauseAudioEvent()),
                ),
                const SizedBox(width: 16),
                IconButton(
                  iconSize: iconSubSize,
                  icon: const Icon(Icons.stop, color: Colors.red),
                  onPressed: () => context.read<SummariesBloc>().add(StopAudioEvent()),
                ),
              ],
            )
          : IconButton(
              key: const ValueKey('play'),
              iconSize: iconMainSize,
              icon: const Icon(Icons.play_arrow, color: ColorConst.orange),
              onPressed: () => context.read<SummariesBloc>().add(PlayAudioEvent()),
            ),
    );
  }
}


