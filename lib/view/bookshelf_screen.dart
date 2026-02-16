import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:logger/logger.dart';
import 'package:reader_mobile/helper/cover_extractor.dart';
import 'package:reader_mobile/repository/database_helper.dart';
import 'package:reader_mobile/view/file/epub_screen.dart';
import 'package:reader_mobile/view/file/pdf_screen.dart';
import 'package:reader_mobile/view/file/fb2_screen.dart';

var logger = Logger(printer: PrettyPrinter());

class BookshelfScreen extends StatefulWidget {
  const BookshelfScreen({super.key});

  @override
  State<StatefulWidget> createState() => _BookshelfScreenState();
}

class _BookshelfScreenState extends State<BookshelfScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late Box _box;
  bool _isLoading = true; // The Hive is loading on startup
  List<String> filePaths = [];

  @override
  void initState() {
    super.initState();
    loadHive();
  }

  Future<void> loadHive() async {
    _box = await Hive.openBox(DatabaseHelper.boxName);
    await loadFilePaths();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> loadFilePaths() async {
    List<String> paths = await dbHelper.getFilePaths();
    setState(() {
      filePaths = paths;
    });
  }

  void openFile(String filePath) {
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

  /// Generic function to navigate to a screen with arguments
  void navigateToScreen<T>({
    required BuildContext context,
    required Widget Function(T) screenBuilder,
    required T arguments,
  }) {
    if (!mounted) return;
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => screenBuilder(arguments)));
  }

  void removeFile(int index) {
    logger.i('Removing file: $index');
    dbHelper.deleteFilePath(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bookshelf')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ValueListenableBuilder(
              valueListenable: _box
                  .listenable(), // Listen to changes in the box
              builder: (context, Box box, _) {
                List<String> filePaths = box.values
                    .cast<String>()
                    .toList(); // Get the current file paths

                return filePaths.isEmpty
                    ? Center(child: Text("No local data"))
                    : ListView.builder(
                        itemCount: filePaths.length,
                        itemBuilder: (context, index) {
                          String filePath = filePaths[index];
                          String fileName = filePath
                              .split('/')
                              .last; // Extract filename

                          final coverExtractor = CoverExtractor();

                          return ListTile(
                            leading: FutureBuilder(
                              future: coverExtractor.extractCover(filePath),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox(
                                    width: 50,
                                    height: 75,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                } else if (snapshot.hasData &&
                                    snapshot.data != null) {
                                  return Image.memory(
                                    snapshot.data!,
                                    width: 50,
                                    height: 75,
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return Container(
                                    width: 50,
                                    height: 75,
                                    color: Colors.amberAccent,
                                    child: Center(child: Icon(Icons.book)),
                                  );
                                }
                              },
                            ),
                            title: Text(fileName),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () => openFile(filePath),
                                  child: Text('Open'),
                                ),
                                SizedBox(width: 5),
                                ElevatedButton(
                                  onPressed: () => removeFile(index),
                                  child: Text('Remove'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
              },
            ),
    );
  }
}
