part of 'detecting_bloc.dart';

@immutable
sealed class DetectingBlocEvent {}

final class StartDetectingEvent extends DetectingBlocEvent {}

final class StopDetectingEvent extends DetectingBlocEvent {}

final class DetectingLicensePlateSucceed extends DetectingBlocEvent {
  final RecognitionModel boundries;
  final String licensePlateText;
  final img.Image licensePlateImage;

  DetectingLicensePlateSucceed({
    required this.boundries,
    required this.licensePlateText,
    required this.licensePlateImage,
  });
}
