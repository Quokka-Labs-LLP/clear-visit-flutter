import 'package:base_architecture/src/shared/constants/image_constants.dart';
import 'package:base_architecture/src/shared/utilities/responsive%20_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({super.key});

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  bool isRecording = true; // Start in recording state as per screenshot

  void _stopRecording() {
    setState(() {
      isRecording = false;
    });
    // Navigate back or to summary page
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Start Recording',
          style: TextStyle(
            color: Color(0xFF1E3A8A), // Dark blue as per screenshot
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
            // Torch icon (orange)
            Image.asset(ImageConst.splashName
            ,height: rpHeight(context, 100),),
            const SizedBox(height: 24),
            // Recording text
            const Text(
              'Recording doctor visit...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A), // Dark blue
              ),
            ),
            const SizedBox(height: 32),
            // Waveform (simulated with animated dots)

            const Spacer(),
            // Stop button
            GestureDetector(
              onTap: _stopRecording,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stop,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const Spacer(),
            // Permission message
            const Text(
              'Please request permission before recording',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
