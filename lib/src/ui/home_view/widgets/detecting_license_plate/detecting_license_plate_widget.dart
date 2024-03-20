import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forest_guard/src/bloc/bloc/detecting_bloc/detecting_bloc.dart';
import 'package:forest_guard/src/bloc/bloc/is_detecting_cubit/is_detecting.dart';
import 'package:forest_guard/src/models/recognition_model.dart';
import 'package:forest_guard/src/constants/screen_params.dart';
import 'package:forest_guard/src/services/detecting_license_plate/cut_image.dart';
import 'package:forest_guard/src/services/detecting_license_plate/license_plate_detector_service.dart';
import 'package:forest_guard/src/services/detecting_license_plate/ocr_cropped_image.dart';
import 'package:image/image.dart' as img;
import 'package:forest_guard/src/services/detecting_log/log_detector_service.dart';
import 'package:forest_guard/src/ui/home_view/widgets/draw_box_rectangle_widget.dart';
import 'package:forest_guard/injection.dart';

/// [LicensePlateDetectorWidget] sends each frame for inference
class LicensePlateDetectorWidget extends StatefulWidget {
  /// Constructor
  const LicensePlateDetectorWidget({super.key});

  @override
  State<LicensePlateDetectorWidget> createState() =>
      _LicensePlateDetectorWidgetState();
}

class _LicensePlateDetectorWidgetState extends State<LicensePlateDetectorWidget>
    with WidgetsBindingObserver {
  /// List of available cameras
  late List<CameraDescription> cameras;

  /// Controller
  CameraController? _cameraController;

  // use only when initialized, so - not null
  get _controller => _cameraController;

  /// Object Detector is running on a background [Isolate]. This is nullable
  /// because acquiring a [LogDetector] is an asynchronous operation. This
  /// value is `null` until the detector is initialized.
  LicensePlateDetector? _detector;
  StreamSubscription? _subscription;
  int frameCount = 15;
  late img.Image savedFrame;
  List<img.Image> croppedImages = [];
  List<String> ocrResults = [];
  int get frameCountValue => frameCount;
  int? selectedCardIndex;
  List resultsList = [];

  /// Results to draw bounding boxes
  List<RecognitionModel>? results;
  var screenParams = sl<ScreenParams>();

  /// Realtime stats
  Map<String, String>? stats;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initStateAsync();
  }

  void _initStateAsync() async {
    int listCount = 0;

    // initialize preview and CameraImage stream
    _initializeCamera();
    // Spawn a new isolate
    LicensePlateDetector.start().then((instance) {
      BlocProvider.of<IsDetectingCubit>(context).startDetecting();

      _detector = instance;
      _subscription = instance.resultsStream.stream.listen((values) async {
        results = values['recognitions'];
        var image = values['image'];
        if (results!.isNotEmpty) {
          resultsList.add(results![0]);
          if (croppedImages.length < 6) {
            croppedImages.add(CroppingImage.cropImage(
                image,
                results![0].location.left,
                results![0].location.top,
                results![0].location.width,
                results![0].location.height));
            stats = values['stats'];
            ocrResults.add(await OCRCroppedImage.oCRImage(croppedImages.last));
          } else {
            if (results!.isNotEmpty) {
              resultsList[listCount] = results![0];

              croppedImages[listCount] = CroppingImage.cropImage(
                  image,
                  results![0].location.left,
                  results![0].location.top,
                  results![0].location.width,
                  results![0].location.height);
              stats = values['stats'];
            }
            ocrResults[listCount] =
                await OCRCroppedImage.oCRImage(croppedImages[listCount]);
          }
          if (listCount == 5) {
            listCount = 0;
          } else {
            listCount++;
          }
          if (mounted) {
            setState(() {});
          }
        }
      });
    });
  }

  /// Initializes the camera by setting [_cameraController]
  void _initializeCamera() async {
    cameras = await availableCameras();
    // cameras[0] for back-camera
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    )..initialize().then((_) async {
        frameCount = 0;
        await _controller.startImageStream(onLatestImageAvailable);
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container while the camera is not initialized
    if (_cameraController == null || !_controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    var aspect = 1 / _controller.value.aspectRatio;

    return Stack(
      fit: StackFit.expand,
      children: [
        AspectRatio(
          aspectRatio: aspect,
          child: CameraPreview(
            _controller,
          ),
        ),
        AspectRatio(
          aspectRatio: aspect,
          child: _croppedImages(),
        ),
        AspectRatio(
          aspectRatio: aspect,
          child: _boundingBoxes(),
        ),
      ],
    );
  }

  /// Returns Stack of bounding boxes
  Widget _boundingBoxes() {
    if (results == null) {
      return const SizedBox.shrink();
    }
    return Stack(
        children: results!
            .map((box) => DrawBoxRectangleWidget(result: box))
            .toList());
  }

  Uint8List encodeImage(img.Image image) {
    // Encode the image to PNG
    List<int> encodedImage = img.encodePng(image);
    // Convert List<int> to Uint8List
    return Uint8List.fromList(encodedImage);
  }

  /// Returns Row of cropped Images
  Widget _croppedImages() {
    if (croppedImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 50,
        ),
        const Center(
            child: Text('Alegeți cea mai potrivită detecție',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold))),
        Expanded(
          child: GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            children: croppedImages.asMap().entries.map((entry) {
              int index = entry.key;
              img.Image image = entry.value;
              return GestureDetector(
                onLongPress: () {
                  enterLicensePlateOnLongPress(index);
                },
                onTap: () {
                  setState(() {
                    if (selectedCardIndex == index) {
                      if (ocrResults[index].isEmpty) {
                        TextEditingController textFieldController =
                            TextEditingController();

                        textFieldController.text = ocrResults[index];
                        //open Textfield dialog to manually add the license plate number
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Enter License Plate Number'),
                              content: TextField(
                                controller: textFieldController,
                                onChanged: (value) {
                                  ocrResults[index] = value;
                                },
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    BlocProvider.of<DetectingBloc>(context).add(
                                        DetectingLicensePlateSucceed(
                                            licensePlateImage:
                                                croppedImages[index],
                                            licensePlateText: ocrResults[index],
                                            boundries: resultsList[index]));
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        BlocProvider.of<DetectingBloc>(context).add(
                            DetectingLicensePlateSucceed(
                                licensePlateImage: croppedImages[index],
                                licensePlateText: ocrResults[index],
                                boundries: resultsList[index]));
                      }

                      // Perform an action if the card is already selected
                    } else {
                      selectedCardIndex = index;
                    }
                  });
                },
                child: lincensePlateCard(index, image),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Card lincensePlateCard(int index, img.Image image) {
    return Card(
      color: selectedCardIndex == index
          ? Colors.green.withOpacity(0.8)
          : Colors.grey.withOpacity(0.6),
      child: SizedBox(
        height: 100,
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ocrResults[index] == "null"
                ? const Text("No License Plate Detected")
                : Text(ocrResults[index],
                    style: const TextStyle(fontSize: 15, color: Colors.white)),
            Image.memory(
              img.encodePng(image),
              scale: 0.3,
            ),
          ],
        ),
      ),
    );
  }

  void enterLicensePlateOnLongPress(int index) {
    TextEditingController textFieldController = TextEditingController();

    textFieldController.text = ocrResults[index];
    //open Textfield dialog to manually add the license plate number
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter License Plate Number'),
          content: TextField(
            controller: textFieldController,
            onChanged: (value) {
              ocrResults[index] = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                BlocProvider.of<DetectingBloc>(context)
                    .add(DetectingLicensePlateSucceed(
                  licensePlateText: ocrResults[index],
                  boundries: resultsList[index],
                  licensePlateImage: croppedImages[index],
                ));
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Callback to receive each frame [CameraImage] perform inference on it
  void onLatestImageAvailable(CameraImage cameraImage) async {
    if (frameCount % 20 == 0) {
      _detector?.processFrame(cameraImage);
    }
    frameCount++;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        _cameraController?.stopImageStream();
        _detector?.stop();
        _subscription?.cancel();
        break;
      case AppLifecycleState.resumed:
        _initStateAsync();
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _detector?.stop();
    _subscription?.cancel();
    super.dispose();
  }
}
