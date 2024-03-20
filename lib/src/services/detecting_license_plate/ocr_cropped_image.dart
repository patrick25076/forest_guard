import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

class OCRCroppedImage {
  static Future<String> oCRImage(img.Image croppedImage) async {
    // Convert img.Image to PNG byte array

    InputImage secondTry =
        InputImage.fromFile(await writeImageToFile(croppedImage));

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(secondTry);
    return recognizedText.text;
  }

  static Future<File> writeImageToFile(img.Image croppedImage) async {
    List<int> pngBytes = img.encodePng(croppedImage);
    Uint8List bytes = Uint8List.fromList(pngBytes);

    // Get a directory to save the file, using the application's documents directory
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    // Define the file path and name
    final file = File('$path/your_image_name.png');

    // Write the byte array as a file
    await file.writeAsBytes(bytes);

    return file;
  }
}
