import 'dart:io'; // For handling file operations
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart'; // For reading local files
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

const double coverImageWidth = 50.0;
const double coverImageHeight = 75.0;

var logger = Logger(printer: PrettyPrinter());

class CoverExtractor {
  // Method to extract cover image from a file
  Future<Uint8List?> extractCover(String filePath) async {
    String fileExtension = filePath.split('.').last.toLowerCase();

    switch (fileExtension) {
      case 'fb2':
        return await _extractFromFb2(filePath);
      case 'pdf':
        return await _extractFromPdf(filePath);
      case 'epub':
        return await _extractFromEpub(filePath);
      default:
        return null; // Unsupported file type
    }
  }

  // Extract cover from FB2 file
  Future<Uint8List?> _extractFromFb2(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final document = XmlDocument.parse(content);

      final coverImageNode = document
          .findAllElements('image')
          .firstWhere(
            (node) => node.getElement('image')?.getElement('src') != null,
          );

      final src = coverImageNode.getElement('src')!.innerText;
      final image = await rootBundle.load(src);
      return image.buffer.asUint8List();
    } catch (e) {
      logger.w('Error extracting FB2 cover image: $e');
    }
    return null;
  }

  // Extract cover from PDF file using pdf_image_renderer
  Future<Uint8List?> _extractFromPdf(String filePath) async {
    try {
      // Initialize the renderer
      final pdf = PdfImageRenderer(path: filePath);

      // open the pdf document
      await pdf.open(
        // password: 'password', // optional (iOS and Android 15.0+ support - ignored otherwise)
      );

      // open a page from the pdf document using the page index
      await pdf.openPage(pageIndex: 0);

      // get the render size after the page is loaded
      final size = await pdf.getPageSize(pageIndex: 0);

      // get the actual image of the page
      final img = await pdf.renderPage(
        pageIndex: 0,
        x: 0,
        y: 0,
        width: size.width, // you can pass a custom size here to crop the image
        height:
            size.height, // you can pass a custom size here to crop the image
        scale: 1, // increase the scale for better quality (e.g. for zooming)
        background: Colors.white,
      );

      // close the page again
      await pdf.closePage(pageIndex: 0);

      // close the PDF after rendering the page
      pdf.close();

      return img;
    } catch (e) {
      logger.w('Error extracting PDF cover image: $e');
    }
    return null;
  }

  // Extract cover from EPUB file
  Future<Uint8List?> _extractFromEpub(String filePath) async {
    try {
      // Read the EPUB file as bytes
      final bytes = await File(filePath).readAsBytes();

      // Decode the ZIP archive
      final archive = ZipDecoder().decodeBytes(bytes);

      // Find the container.xml file in the META-INF directory
      final containerXmlFile = archive.files.firstWhere(
        (file) => file.name == 'META-INF/container.xml',
        orElse: () => throw Exception('container.xml not found'),
      );

      // Parse the container.xml file to find the rootfile
      final containerXml = XmlDocument.parse(
        Utf8Decoder().convert(containerXmlFile.content),
      );
      final rootfilePath = containerXml
          .findAllElements('rootfile')
          .first
          .getAttribute('full-path');
      if (rootfilePath == null) {
        throw Exception('rootfile not found in container.xml');
      }

      // Find the rootfile (usually content.opf) in the archive
      final rootfile = archive.files.firstWhere(
        (file) => file.name == rootfilePath,
        orElse: () => throw Exception('rootfile not found in archive'),
      );

      // Parse the rootfile to find the cover image reference
      final rootfileXml = XmlDocument.parse(
        Utf8Decoder().convert(rootfile.content),
      );
      final metadata = rootfileXml.findAllElements('metadata').first;
      final coverId = metadata
          .findAllElements('meta')
          .firstWhere(
            (meta) => meta.getAttribute('property') == 'cover-image',
            orElse: () => throw Exception('cover-image meta not found'),
          )
          .getAttribute('content');

      if (coverId == null) {
        throw Exception('cover image ID not found');
      }

      // Find the cover image file in the manifest
      final manifest = rootfileXml.findAllElements('manifest').first;
      final coverItem = manifest
          .findAllElements('item')
          .firstWhere(
            (item) => item.getAttribute('id') == coverId,
            orElse: () => throw Exception('cover image item not found'),
          );
      final coverHref = coverItem.getAttribute('href');
      if (coverHref == null) {
        throw Exception('cover image href not found');
      }

      // Find the cover image file in the archive
      final coverFile = archive.files.firstWhere(
        (file) => file.name == coverHref,
        orElse: () => throw Exception('cover image file not found'),
      );

      // Return the cover image bytes
      return Uint8List.fromList(coverFile.content);
    } catch (e) {
      logger.w('Error extracting EPUB cover: $e');
      return null;
    }
  }
}
