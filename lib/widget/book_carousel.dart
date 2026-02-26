import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:reader_mobile/widget/book_plate.dart';

var logger = Logger(printer: PrettyPrinter());

class BookCarousel extends StatelessWidget {
  final Box box;

  final Function(String)? onBookTap;

  const BookCarousel({super.key, required this.box, this.onBookTap});

  @override
  Widget build(BuildContext context) {
    List<String> filePaths = box.values.cast<String>().toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the height based on the book cover height plus some padding
        final coverHeight = 134.0; // Height of the book cover
        final padding = 20.0; // Additional padding around the cover
        final carouselHeight = coverHeight + padding;

        return SizedBox(
          height: carouselHeight, // Height based on cover and padding
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filePaths.length,
            itemBuilder: (context, index) {
              String filePath = filePaths[index];
              String fileName = filePath.split('/').last;

              return Container(
                margin: const EdgeInsets.all(2.0),
                child: BookPlate(
                  filePath: filePath,
                  fileName: fileName,
                  width: 105,
                  coverHeight: carouselHeight,
                  onTap: onBookTap,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
