import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import 'package:reader_mobile/view/bookshelf_screen.dart';
import '../repository/database_helper.dart';

var logger = Logger(printer: PrettyPrinter());

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false; // Loading indicator for a file upload
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> _pickFile() async {
    setLoadingState(true);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'fb2', 'epub'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      logger.i('Opened file: $filePath');
    }

    setLoadingState(false);

    if (result != null) {
      String filePath = result.files.single.path!;
      logger.i('Opened file: $filePath');
      await dbHelper.addFilePath(filePath);
    } else {
      logger.i('Canceled file dialog');
    }
  }

  void setLoadingState(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(children: [Expanded(child: BookshelfScreen())]),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        tooltip: 'Upload a file',
        child: _isLoading ? CircularProgressIndicator() : Icon(Icons.download),
      ),
    );
  }
}
