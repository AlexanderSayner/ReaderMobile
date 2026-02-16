import 'package:hive_flutter/hive_flutter.dart';

class DatabaseHelper {
  static const String boxName = 'filePathBox';

  Future<void> addFilePath(String path) async {
    var box = await Hive.openBox(boxName);
    await box.add(path); // Add the file path to the box
  }

  Future<List<String>> getFilePaths() async {
    var box = await Hive.openBox(boxName);
    return box.values.cast<String>().toList(); // Retrieve all file paths
  }

  Future<void> deleteFilePath(int index) async {
    var box = await Hive.openBox(boxName);
    await box.deleteAt(index); // Delete a file path by index
  }
}
