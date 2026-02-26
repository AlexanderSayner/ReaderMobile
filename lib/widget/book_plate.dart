import 'package:flutter/material.dart';
import 'package:reader_mobile/helper/cover_extractor.dart';

class BookPlate extends StatelessWidget {
  final String filePath;
  final String fileName;
  final double width;
  final double height;
  final double coverWidth;
  final double coverHeight;
  final Function(String)? onTap;

  const BookPlate({
    super.key,
    required this.filePath,
    required this.fileName,
    this.width = 120,
    this.height = 180,
    this.coverWidth = 120,
    this.coverHeight = 150,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final coverExtractor = CoverExtractor();

    return FutureBuilder(
      future: coverExtractor.extractCover(filePath),
      builder: (context, snapshot) {
        Widget coverWidget;
        if (snapshot.connectionState == ConnectionState.waiting) {
          coverWidget = SizedBox(
            width: coverWidth,
            height: coverHeight,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          coverWidget = Image.memory(
            snapshot.data!,
            width: coverWidth,
            height: coverHeight,
            fit: BoxFit.cover,
          );
        } else {
          coverWidget = Container(
            width: coverWidth,
            height: coverHeight,
            color: Colors.amberAccent,
            child: Center(
              child: fileName.isNotEmpty ? Text(fileName) : const Icon(Icons.book),
            ),
          );
        }

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Expanded(child: Center(child: coverWidget)),
              /*Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  fileName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),*/
            ],
          ),
        );
      },
    );
  }
}
