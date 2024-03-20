import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as image_lib;

/// This file contains utility functions for converting images from the
/// `CameraImage` format used by the `camera` package to the `Image` format
/// used by the `image` package.
///
/// The `convertCameraImageToImage` function is the main entry point. It takes
/// a `CameraImage` and returns a `Future` that completes with an `Image`.
/// The function checks the format of the `CameraImage` and calls the appropriate
/// conversion function.
///
/// Currently, the following formats are supported:
/// - YUV420
/// - BGRA8888
/// - JPEG
/// - NV21
///
/// The `convertYUV420ToImage` function is an example of a conversion function.
/// It takes a `CameraImage` in YUV420 format and returns an `Image`.
/// The function extracts the Y, U, and V planes from the `CameraImage` and
/// uses them to create the `Image`.
///
/// Other conversion functions (not shown in this excerpt) work in a similar way.

Future<image_lib.Image?> convertCameraImageToImage(
    CameraImage cameraImage) async {
  image_lib.Image image;

  if (cameraImage.format.group == ImageFormatGroup.yuv420) {
    image = convertYUV420ToImage(cameraImage);
  } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
    image = convertBGRA8888ToImage(cameraImage);
  } else if (cameraImage.format.group == ImageFormatGroup.jpeg) {
    image = convertJPEGToImage(cameraImage);
  } else if (cameraImage.format.group == ImageFormatGroup.nv21) {
    image = convertNV21ToImage(cameraImage);
  } else {
    return null;
  }

  return image;
}

image_lib.Image convertYUV420ToImage(CameraImage cameraImage) {
  final width = cameraImage.width;
  final height = cameraImage.height;

  final uvRowStride = cameraImage.planes[1].bytesPerRow;
  final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

  final yPlane = cameraImage.planes[0].bytes;
  final uPlane = cameraImage.planes[1].bytes;
  final vPlane = cameraImage.planes[2].bytes;

  final image = image_lib.Image(width: width, height: height);

  var uvIndex = 0;

  for (var y = 0; y < height; y++) {
    var pY = y * width;
    var pUV = uvIndex;

    for (var x = 0; x < width; x++) {
      final yValue = yPlane[pY];
      final uValue = uPlane[pUV];
      final vValue = vPlane[pUV];

      final r = yValue + 1.402 * (vValue - 128);
      final g = yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128);
      final b = yValue + 1.772 * (uValue - 128);

      image.setPixelRgba(x, y, r.toInt(), g.toInt(), b.toInt(), 255);

      pY++;
      if (x % 2 == 1 && uvPixelStride == 2) {
        pUV += uvPixelStride;
      } else if (x % 2 == 1 && uvPixelStride == 1) {
        pUV++;
      }
    }

    if (y % 2 == 1) {
      uvIndex += uvRowStride;
    }
  }
  return image;
}

image_lib.Image convertBGRA8888ToImage(CameraImage cameraImage) {
  // Extract the bytes from the CameraImage
  final bytes = cameraImage.planes[0].bytes;

  // Create a new Image instance
  final image = image_lib.Image.fromBytes(
    width: cameraImage.width,
    height: cameraImage.height,
    bytes: bytes.buffer,
    order: image_lib.ChannelOrder.rgba,
  );

  return image;
}

image_lib.Image convertJPEGToImage(CameraImage cameraImage) {
  // Extract the bytes from the CameraImage
  final bytes = cameraImage.planes[0].bytes;

  // Create a new Image instance from the JPEG bytes
  final image = image_lib.decodeImage(bytes);

  return image!;
}

image_lib.Image convertNV21ToImage(CameraImage cameraImage) {
  // Extract the bytes from the CameraImage
  final yuvBytes = cameraImage.planes[0].bytes;
  final vuBytes = cameraImage.planes[1].bytes;

  // Create a new Image instance
  final image = image_lib.Image(
    width: cameraImage.width,
    height: cameraImage.height,
  );

  // Convert NV21 to RGB
  convertNV21ToRGB(
    yuvBytes,
    vuBytes,
    cameraImage.width,
    cameraImage.height,
    image,
  );

  return image;
}

void convertNV21ToRGB(Uint8List yuvBytes, Uint8List vuBytes, int width,
    int height, image_lib.Image image) {
  // Conversion logic from NV21 to RGB
  // ...

  // Example conversion logic using the `imageLib` package
  // This is just a placeholder and may not be the most efficient method
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final yIndex = y * width + x;
      final uvIndex = (y ~/ 2) * (width ~/ 2) + (x ~/ 2);

      final yValue = yuvBytes[yIndex];
      final uValue = vuBytes[uvIndex * 2];
      final vValue = vuBytes[uvIndex * 2 + 1];

      // Convert YUV to RGB
      final r = yValue + 1.402 * (vValue - 128);
      final g = yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128);
      final b = yValue + 1.772 * (uValue - 128);

      // Set the RGB pixel values in the Image instance
      image.setPixelRgba(x, y, r.toInt(), g.toInt(), b.toInt(), 255);
    }
  }
}

/// ROTATION changes - not working as need to be from the Exif (which is empty)

Future<int> getExifRotation(CameraImage cameraImage) async {
  final exifData = await readExifFromBytes(cameraImage.planes[0].bytes);
  final ifd = exifData['Image Orientation'];

  if (ifd != null) {
    return ifd.values.toList()[0];
  }
  return 1;
}

image_lib.Image applyExifRotation(image_lib.Image image, int exifRotation) {
  if (exifRotation == 1) {
    return image_lib.copyRotate(image, angle: 0);
  } else if (exifRotation == 3) {
    return image_lib.copyRotate(image, angle: 180);
  } else if (exifRotation == 6) {
    return image_lib.copyRotate(image, angle: 90);
  } else if (exifRotation == 8) {
    return image_lib.copyRotate(image, angle: 270);
  }

  return image;
}

Future<void> saveImage(
  image_lib.Image image,
  String path,
  String name,
) async {
  Uint8List bytes = image_lib.encodeJpg(image);
  final fileOnDevice = File('$path/$name.jpg');
  await fileOnDevice.writeAsBytes(bytes, flush: true);
}
