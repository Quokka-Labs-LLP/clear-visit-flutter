import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfParams {
  final Uint8List imageBytes;
  final RootIsolateToken rootIsolateToken;
  PdfParams(this.imageBytes, this.rootIsolateToken);
}

Future<File> pdfWorker(PdfParams params) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(params.rootIsolateToken);

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/summary.pdf');

  final pdf = pw.Document();
  final image = pw.MemoryImage(params.imageBytes);
  pdf.addPage(
    pw.Page(build: (_) => pw.Center(child: pw.Image(image))),
  );

  await file.writeAsBytes(await pdf.save());

  return file; // ✅ Return the File
}

