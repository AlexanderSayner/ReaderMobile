import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:hive_flutter/hive_flutter.dart';
import 'view/home_page.dart';

final String appFolderName = 'FlutterReader';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  final documents = await getApplicationDocumentsDirectory();
  final customDir = Directory(p.join(documents.path, appFolderName));
  if (!await customDir.exists()) {
    await customDir.create(recursive: true);
  }

  await Hive.initFlutter(
    customDir.path,
  ); // Initialize Hive with the app's document directory

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Reader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Reader Home Page'),
    );
  }
}
