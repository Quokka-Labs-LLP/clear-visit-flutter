import 'package:flutter/material.dart';
import 'package:base_architecture/src/features/home/presentation/bloc/summaries_bloc.dart';

import '../../../../../shared/constants/color_constants.dart';

class SummaryContent extends StatelessWidget {
  final SummariesState state;
  final GlobalKey boundaryKey;

  const SummaryContent({super.key, required this.state, required this.boundaryKey});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: boundaryKey,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.summaryModel?.doctorName == null
                  ? "Doctor"
                  : "Dr. ${state.summaryModel?.doctorName}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorConst.orange
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatFullDateTime(
                state.summaryModel?.createdAt?.toDate() ?? DateTime.now(),
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                  color: ColorConst.orange
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.summaryModel?.summaryText ?? 'No summary available',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            if (state.summaryModel?.followUpQuestions?.isNotEmpty ?? false) ...[
              const Text(
                'Follow-up Questions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                    color: ColorConst.orange
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
                          color: ColorConst.orange,
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
    );
  }

  String _formatFullDateTime(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}/"
        "${dateTime.month.toString().padLeft(2, '0')}/"
        "${dateTime.year}  "
        "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";
  }
}


