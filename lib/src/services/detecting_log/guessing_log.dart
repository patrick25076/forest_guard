import 'dart:math' as math;

import 'package:forest_guard/src/models/recognition_model.dart';

class GuessingLog {
  static double getEstimatedVolume(
      List<RecognitionModel> results, double ratio, double logLengthCm) {
    // The known length of the logs in cm.
    double logLength = logLengthCm; // 3m

    double totalVolume = 0;

    for (var rect in results) {
      // Calculate the diameter in pixels (assuming the log is oriented horizontally).
      double diameterPx;
      if (rect.renderLocation.width >= rect.renderLocation.height) {
        diameterPx = rect.renderLocation.width;
      } else {
        diameterPx = rect.renderLocation.height;
      }

      // Convert the diameter to cm.
      double diameterCm = diameterPx * ratio;
      // Calculate the radius in cm.
      double radiusCm = diameterCm / 2;

      // Calculate the volume of the log in cubic cm.
      double volumeCm3 = math.pi * math.pow(radiusCm, 2) * logLength;
      // Add the volume to the total volume.
      totalVolume += volumeCm3;
    }
    totalVolume = totalVolume / 1000000;
    if (totalVolume == 0) {
      throw Exception('Failed to get estimated volume');
    }

    return totalVolume;
  }
}
