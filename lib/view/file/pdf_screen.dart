import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

var logger = Logger(printer: PrettyPrinter());

class PdfNetViewerScreen extends StatefulWidget {
  final String pdfSource;

  const PdfNetViewerScreen({super.key, required this.pdfSource});

  @override
  State<StatefulWidget> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfNetViewerScreen> {
  String? _localFilePath;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.pdfSource.startsWith('http')) {
      _downloadPdf(widget.pdfSource);
    } else {
      _localFilePath = widget.pdfSource; // Local asset path consumed
    }
  }

  // Supports either assets file path and a web link
  Future<void> _downloadPdf(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/downloaded.pdf');
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          _localFilePath = file.path;
        });
      } else {
        _handleError('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      _handleError('Error downloading PDF: $e');
      logger.e('Exception during PDF downloading');
    }
  }

  void _handleError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  // Displays pdf or an error message if failed to download
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Viewer screen for pdf files')),
      body: _errorMessage != null
          ? Center(
              child: Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            )
          : _localFilePath != null
          ? SfPdfViewer.file(File(_localFilePath!))
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
