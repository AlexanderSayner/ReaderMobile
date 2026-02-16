import 'dart:io';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class Fb2ViewerScreen extends StatefulWidget {
  final String fb2FilePath;

  const Fb2ViewerScreen({super.key, required this.fb2FilePath});

  @override
  State<StatefulWidget> createState() => _Fb2ViewerScreenState();
}

class _Fb2ViewerScreenState extends State<Fb2ViewerScreen> {
  String? _title;
  String? _author;
  String? _body;

  @override
  void initState() {
    super.initState();
    _parseFb2File(widget.fb2FilePath);
  }

  Future<void> _parseFb2File(String path) async {
    final file = File(path);
    if (await file.exists()) {
      final content = await file.readAsString();
      final document = XmlDocument.parse(content);

      //final titleeElement = document.findAllElements('title').first;
      // _title = titleeElement.innerText;

      final authorElement = document.findAllElements('author').first;
      _author = authorElement.innerText;

      final bodyElement = document.findAllElements('body').first;
      _body = bodyElement.innerText;

      setState(() {}); // Updates the UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FB2 viewer screen')),
      body: _body != null
          ? Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title ?? 'Unknown Title',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _author ?? 'Unknown Author',
                            style: const TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _body ?? '',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
