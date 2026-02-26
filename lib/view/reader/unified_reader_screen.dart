import 'package:flutter/material.dart';
import 'package:reader_mobile/view/file/pdf_screen.dart';
import 'package:reader_mobile/view/file/fb2_screen.dart';
import 'package:reader_mobile/view/file/epub_screen.dart';

class UnifiedReaderWrapper extends StatelessWidget {
  final String filePath;
  final String fileType;

  const UnifiedReaderWrapper({
    super.key,
    required this.filePath,
    required this.fileType,
  });

  @override
  Widget build(BuildContext context) {
    // Apply consistent styling to all reader types
    return Scaffold(
      appBar: AppBar(
        title: Text('Reading: ${filePath.split('/').last}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.grey[100], // Consistent background color
        child: _buildReader(context),
      ),
    );
  }

  Widget _buildReader(BuildContext context) {
    // Wrap the existing viewers with consistent styling
    switch (fileType) {
      case '.pdf':
        return _wrapWithSelection(
          child: PdfNetViewerScreen(pdfSource: filePath),
        );
      case '.fb2':
        return _wrapWithSelection(
          child: Fb2ViewerScreen(fb2FilePath: filePath),
        );
      case '.epub':
        return _wrapWithSelection(
          child: EpubViewerScreen(epubPath: filePath),
        );
      default:
        return const Center(
          child: Text('Unsupported file format'),
        );
    }
  }

  Widget _wrapWithSelection({required Widget child}) {
    // Wrap the reader with SelectionArea for consistent text selection
    return SelectionArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: child,
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 200,
          child: Column(
            children: [
              const Text('Reading Settings', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              // Add your settings widgets here
              // For example: font size slider, theme selection, etc.
              const Text('Font Size'),
              Slider(
                value: 16,
                min: 12,
                max: 24,
                onChanged: (value) {
                  // Handle font size change
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
