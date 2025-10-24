import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PDFMapViewer extends StatelessWidget {
  final PdfController pdfController;

  const PDFMapViewer({super.key, required this.pdfController});

  @override
  Widget build(BuildContext context) {
    return PdfView(
      controller: pdfController,
      scrollDirection: Axis.vertical,
    );
  }
}
