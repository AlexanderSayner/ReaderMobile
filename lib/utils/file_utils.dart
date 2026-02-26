import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:logger/logger.dart';
import 'package:reader_mobile/repository/database_helper.dart';
import 'package:reader_mobile/view/file/epub_screen.dart';
import 'package:reader_mobile/view/file/pdf_screen.dart';
import 'package:reader_mobile/view/file/fb2_screen.dart';
import 'package:reader_mobile/view/reader/unified_reader_screen.dart';

var logger = Logger(printer: PrettyPrinter());
var dbHelper = DatabaseHelper();
/*
Future<void> openFile({
  required BuildContext context,
  required String filePath,
}) async {
  String fileExtension = p.extension(filePath);
  logger.i('Opening file: $filePath as $fileExtension type');

  switch (fileExtension) {
    case '.pdf':
      navigateToScreen<String>(
        context: context,
        screenBuilder: (path) => PdfNetViewerScreen(pdfSource: path),
        arguments: filePath,
      );
      break;
    case '.fb2':
      navigateToScreen<String>(
        context: context,
        screenBuilder: (path) => Fb2ViewerScreen(fb2FilePath: path),
        arguments: filePath,
      );
      break;
    case '.epub':
      navigateToScreen(
        context: context,
        screenBuilder: (path) => EpubViewerScreen(epubPath: path),
        arguments: filePath,
      );
    default:
      logger.w('Unsupported file type: $fileExtension');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unsupported file type: $fileExtension')),
      );
  }
}
*/

 Future<void> openFile({
  required BuildContext context,
  required String filePath,
}) async {
  String fileExtension = p.extension(filePath);
  logger.i('Opening file: $filePath as $fileExtension type');

  // Always use the unified reader wrapper regardless of file type
  navigateToScreen(
    context: context,
    screenBuilder: (path) => UnifiedReaderWrapper(
      filePath: path,
      fileType: fileExtension,
    ),
    arguments: filePath,
  );
}

void navigateToScreen<T>({
  required BuildContext context,
  required Widget Function(T) screenBuilder,
  required T arguments,
}) {
  if (context.mounted) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => screenBuilder(arguments)));
  }
}

Future<void> pickAndUploadFile({
  required BuildContext context,
  required ValueNotifier<bool> isLoading,
}) async {
  isLoading.value = true;

  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'fb2', 'epub'],
  );

  if (result != null) {
    String filePath = result.files.single.path!;
    logger.i('Selected file: $filePath');
    await dbHelper.addFilePath(filePath);
  } else {
    logger.i('Canceled file dialog');
  }

  isLoading.value = false;
}
