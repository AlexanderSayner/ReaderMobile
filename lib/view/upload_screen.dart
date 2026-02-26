import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:reader_mobile/repository/database_helper.dart';
import 'package:reader_mobile/utils/file_utils.dart' as file_utils;
import 'package:reader_mobile/widget/book_plate.dart';

var logger = Logger(printer: PrettyPrinter());

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<StatefulWidget> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  late Box _box;
  bool _isInitLoading = true;

  @override
  void initState() {
    super.initState();
    loadHive();
  }

  Future<void> loadHive() async {
    _box = await Hive.openBox(DatabaseHelper.boxName);
    setState(() {
      _isInitLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Books')),
      body: _isInitLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Divider(),
                // Upload button row
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const VerticalDivider(thickness: 1, width: 20),
                      ValueListenableBuilder<bool>(
                        valueListenable: _isLoading,
                        builder: (context, isLoading, child) {
                          return ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => file_utils.pickAndUploadFile(
                                    context: context,
                                    isLoading: _isLoading,
                                  ),
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : const Text('Upload File'),
                          );
                        },
                      ),
                      const VerticalDivider(thickness: 1, width: 20),
                    ],
                  ),
                ),
                const Divider(),
                // Grid of uploaded books
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: _box.listenable(),
                    builder: (context, Box box, _) {
                      List<String> filePaths = box.values
                          .cast<String>()
                          .toList();

                      return filePaths.isEmpty
                          ? const Center(child: Text("No uploaded books"))
                          : GridView.builder(
                              padding: const EdgeInsets.all(8.0),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent:
                                        150, // Maximum width of a grid item
                                    childAspectRatio:
                                        0.7, // Width to height ratio
                                    crossAxisSpacing:
                                        8, // Horizontal space between items
                                    mainAxisSpacing:
                                        8, // Vertical space between items
                                  ),
                              itemCount: filePaths.length,
                              itemBuilder: (context, index) {
                                String filePath = filePaths[index];
                                String fileName = filePath.split('/').last;

                                return BookPlate(
                                  filePath: filePath,
                                  fileName: fileName,
                                  coverWidth: 150,
                                  coverHeight: 214,
                                  onTap: (filePath) => file_utils.openFile(
                                    context: context,
                                    filePath: filePath,
                                  ),
                                );
                              },
                            );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
