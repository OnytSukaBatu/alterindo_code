import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:logger/logger.dart';

class PdfReader extends StatefulWidget {
  final String pdfData;
  final File? file;

  const PdfReader({
    super.key,
    required this.pdfData,
    required this.file,
  });

  @override
  State<PdfReader> createState() => _PdfReaderState();
}

Uint8List base64ToUint8List(String base64String) {
  return base64Decode(base64String);
}

class _PdfReaderState extends State<PdfReader> {
  Logger logger = Logger(
    printer: PrettyPrinter(
      lineLength: 60,
    ),
  );

  Future<Uint8List?> _getPdfBytes() async {
    if (widget.file != null) {
      return await widget.file!.readAsBytes();
    } else {
      return base64ToUint8List(widget.pdfData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: FutureBuilder<Uint8List?>(
        future: _getPdfBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            logger.t('Error: ${snapshot.error}');
            return Center(child: Text('Error loading PDF'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No PDF data available'));
          } else {
            final pdfBytes = snapshot.data!;
            return PDFView(
              pdfData: pdfBytes,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: true,
              pageSnap: true,
              onRender: (pages) {
                logger.t('PDF rendered with $pages pages');
              },
              onError: (error) {
                logger.t('Error: $error');
              },
              onPageError: (page, error) {
                logger.t('Page error: $page, $error');
              },
            );
          }
        },
      ),
    );
  }
}
