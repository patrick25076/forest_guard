part of 'detecting_bloc.dart';

@immutable
sealed class DetectingBlocState {}

final class DetectingBlocInitial extends DetectingBlocState {}

final class DetectingLicensePlate extends DetectingBlocState {
  final SnackBar? snackbar;

  DetectingLicensePlate({this.snackbar});
}

final class DetecingLicensePlateSuccessState extends DetectingBlocState {
  final RecognitionModel boundries;
  final String licensePlateText;
  final img.Image licensePlateImage;

  DetecingLicensePlateSuccessState({
    required this.licensePlateText,
    required this.boundries,
    required this.licensePlateImage,
  });
}

final class DetectingLoading extends DetectingBlocState {}

final class OCRAndGuessingSuccess extends DetectingBlocState {}

final class DetectingLog extends DetectingBlocState {
  final String licensePlateText;
  final double ratio;
  final String legalWoodVolume;

  DetectingLog({
    required this.licensePlateText,
    required this.ratio,
    required this.legalWoodVolume,
  });
}

final class LogDetectionSuccess extends DetectingBlocState {}
