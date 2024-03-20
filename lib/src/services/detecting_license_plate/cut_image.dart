import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class CroppingImage {
  static img.Image cropImage(img.Image originalImage, double x, double y,
      double width, double height) {
    try {
      // Scale factor
      // Scale the bounding box coordinates
      width = width * originalImage.width;
      height = height * originalImage.height;
      if (height < 32 || height > width) {
        height = 32;
      }

      if (width < 32) {
        width = 32;
      }

      final scaledBoundingBox = Rect.fromLTWH(
        x * originalImage.width,
        y * originalImage.height,
        width,
        height,
      );

      // Crop the image
      final croppedImage = img.copyCrop(
        originalImage,
        x: scaledBoundingBox.left.round(),
        y: scaledBoundingBox.top.round(),
        width: scaledBoundingBox.width.round(),
        height: scaledBoundingBox.height.round(),
      );
      return croppedImage;
    } catch (e) {
      throw Exception('Failed to crop image');
    }
  }
}
