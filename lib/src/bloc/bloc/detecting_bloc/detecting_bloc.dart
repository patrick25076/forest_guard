import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forest_guard/src/models/recognition_model.dart';
import 'package:forest_guard/src/services/detecting_license_plate/guessing_pixels.dart';
import 'package:forest_guard/src/services/detecting_license_plate/scraping.dart';
import 'package:image/image.dart' as img;

part 'detecting_bloc_event.dart';
part 'detecting_bloc_state.dart';

class DetectingBloc extends Bloc<DetectingBlocEvent, DetectingBlocState> {
  DetectingBloc() : super(DetectingBlocInitial()) {
    on<DetectingBlocEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<StartDetectingEvent>((event, emit) {
      emit(DetectingLicensePlate());
    });
    on<StopDetectingEvent>((event, emit) {
      emit(DetectingBlocInitial());
    });

    on<DetectingLicensePlateSucceed>((event, emit) async {
      emit(DetectingLoading());
      String scrappedLicensePlate =
          await ScrappingData.scrappingData(event.licensePlateText);

      if (scrappedLicensePlate == 'Invalid Number!') {
        SnackBar snackBar = const SnackBar(
          content: Text('Invalid License Plate! Please try again!'),
        );
        try {
          emit(DetectingLicensePlate(snackbar: snackBar));
        } catch (e) {
          throw Exception('Error');
        }
      } else {
        try {
          GuessingPixels.calculatePixelToCmRatio(
              event.licensePlateImage.width * 1);

          emit(DetectingLog(
              licensePlateText: event.licensePlateText,
              ratio: GuessingPixels.calculatePixelToCmRatio(
                  event.licensePlateImage.width.toDouble()),
              legalWoodVolume: scrappedLicensePlate));
        } catch (e) {
          throw Exception('Error');
        }
      }
    });
  }
}
