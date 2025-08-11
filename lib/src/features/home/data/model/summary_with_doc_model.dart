import 'package:base_architecture/src/features/home/data/model/summary_model.dart';

class SummaryWithDoctorName {
  final SummaryModel summary;
  final String doctorName;

  SummaryWithDoctorName({
    required this.summary,
    required this.doctorName,
  });
}