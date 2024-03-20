class GuessingPixels {
  static double calculatePixelToCmRatio(double licensePlateWidthPx) {
    const licensePlateWidthCm = 52;

    // The ratio of pixels to cm.
    double pxToCmRatio = licensePlateWidthCm / licensePlateWidthPx;

    return pxToCmRatio;
  }
}
