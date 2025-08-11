import 'package:base_architecture/src/shared/constants/image_constants.dart';
import 'package:base_architecture/src/shared/utilities/responsive%20_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../app/router/route_const.dart';
import '../bloc/recording/recording_bloc.dart';

class RecordingPage extends StatefulWidget {
  final String? doctorId;
  const RecordingPage({super.key, this.doctorId});

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecordingBloc()..add(const RecordingInitialize()),
      child: BlocConsumer<RecordingBloc, RecordingState>(
        listener: (context, state) {
          if (state.completedFilePath != null) {
            context.goNamed(
              RouteConst.summaryScreen,
              extra: {
                'filePath': state.completedFilePath,
                'doctorId': widget.doctorId,
              },
            );
            context.read<RecordingBloc>().add(const RecordingNavigationHandled());
          }
          if (state.permissionStatus == MicPermissionStatus.denied) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Microphone permission not granted')),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          final isRecording = state.isRecording;
          final isPaused = state.isPaused ?? false;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text(
                'Start Recording',
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
            body: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Image.asset(
                    ImageConst.splashName,
                    height: rpHeight(context, 100),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Recording doctor visit...',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Lottie.asset(
                    ImageConst.waveformAnimation,
                    height: rpHeight(context, 180),
                    animate: isRecording,
                    repeat: true,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Main Record / Stop Button
                      GestureDetector(
                        onTap: () {
                          final bloc = context.read<RecordingBloc>();
                          if (isRecording) {
                            bloc.add(const RecordingStop());
                          } else {
                            bloc.add(const RecordingStart());
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isRecording ? Colors.red : Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isRecording ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),

                      // Animated pause/resume button (only visible when recording or paused)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: (isRecording || isPaused)
                            ? Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: GestureDetector(
                            key: ValueKey<bool>(isPaused), // to trigger animation on toggle
                            onTap: () {
                              final bloc = context.read<RecordingBloc>();
                              bloc.add(const RecordingPauseOrResume());
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPaused ? Icons.play_arrow : Icons.pause,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Text(
                    state.permissionStatus == MicPermissionStatus.granted
                        ? isRecording
                        ? (isPaused ? 'Tap to resume recording' : 'Tap to stop or pause recording')
                        : 'Tap to start recording'
                        : 'Microphone permission required',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
