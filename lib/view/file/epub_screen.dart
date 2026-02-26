import 'dart:io';

import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';

class EpubViewerScreen extends StatefulWidget {
  final String epubPath;

  const EpubViewerScreen({super.key, required this.epubPath});

  @override
  State<EpubViewerScreen> createState() => _EpubViewerScreenState();
}

class _EpubViewerScreenState extends State<EpubViewerScreen> {
  late EpubController _epubController;

  @override
  void initState() {
    super.initState();
    _epubController = EpubController(
      document: EpubDocument.openFile(File(widget.epubPath)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('EPUB Viewer')),
      body: EpubView(
        controller: _epubController,
      ),
    );
  }

  @override
  void dispose() {
    _epubController.dispose();
    super.dispose();
  }
}
