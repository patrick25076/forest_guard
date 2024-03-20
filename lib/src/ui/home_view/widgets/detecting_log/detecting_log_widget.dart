import 'dart:async';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forest_guard/src/bloc/bloc/detecting_bloc/detecting_bloc.dart';
import 'package:forest_guard/src/bloc/bloc/is_detecting_cubit/is_detecting.dart';
import 'package:forest_guard/src/bloc/bloc/sqflite_bloc/sqflite_bloc.dart';
import 'package:forest_guard/src/entitys/verified_truck_entity.dart';
import 'package:forest_guard/src/models/recognition_model.dart';
import 'package:forest_guard/src/constants/screen_params.dart';
import 'package:forest_guard/src/services/detecting_log/guessing_log.dart';
import 'package:forest_guard/src/services/detecting_log/log_detector_service.dart';
import 'package:forest_guard/src/ui/home_view/widgets/draw_box_rectangle_widget.dart';
import 'package:forest_guard/injection.dart';

/// [LogDetectorWidget] sends each frame for inference
class LogDetectorWidget extends StatefulWidget {
  /// Constructor
  const LogDetectorWidget({
    super.key,
    required this.ratio,
    required this.licensePlateText,
    required this.legalWoodVolume,
  });
  final double ratio;
  final String licensePlateText;
  final String legalWoodVolume;
  @override
  State<LogDetectorWidget> createState() => _LogDetectorWidgetState();
}

class _LogDetectorWidgetState extends State<LogDetectorWidget>
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
  LogDetector? _detector;
  StreamSubscription? _subscription;
  int frameCount = 15;

  int get frameCountValue => frameCount;

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
    // initialize preview and CameraImage stream
    _initializeCamera();
    // Spawn a new isolate
    LogDetector.start().then((instance) {
      if (mounted) {
        setState(() {
          BlocProvider.of<IsDetectingCubit>(context).startDetecting();
          _detector = instance;
          _subscription = instance.resultsStream.stream.listen((values) {
            if (mounted) {
              setState(() {
                results = values['recognitions'];
                stats = values['stats'];
              });
            }
          });
        });
      }
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
        // Bounding boxes
        AspectRatio(
          aspectRatio: aspect,
          child: _boundingBoxes(),
        ),
        Column(
          children: [
            const Spacer(),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              color: Colors.grey.withOpacity(0.6),
              child: IconButton(
                icon: const Icon(Icons.check, color: Colors.green, size: 90),
                onPressed: () async {
                  if (results != null) {
                    // opens a dialog where you can enter the length of the truck
                    var estimatedVolume = await showDialog<double>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Enter the length of the truck'),
                          content: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Length in meters',
                            ),
                            onSubmitted: (String value) {
                              Navigator.of(context).pop(
                                  GuessingLog.getEstimatedVolume(results!,
                                      widget.ratio, double.parse(value)));
                            },
                          ),
                        );
                      },
                    );
                    VerifiedTruckEntity verifiedTruckEntity;
                    if (estimatedVolume != null) {
                      verifiedTruckEntity = VerifiedTruckEntity(
                          licensePlate: widget.licensePlateText.toUpperCase(),
                          timestamp: DateTime.now(),
                          estimatedWoodVolume: estimatedVolume,
                          legalWoodVolume:
                              double.parse(widget.legalWoodVolume));
                    } else {
                      estimatedVolume = GuessingLog.getEstimatedVolume(
                          results!, widget.ratio, 800);
                      verifiedTruckEntity = VerifiedTruckEntity(
                          licensePlate: widget.licensePlateText.toUpperCase(),
                          timestamp: DateTime.now(),
                          estimatedWoodVolume: estimatedVolume,
                          legalWoodVolume:
                              double.parse(widget.legalWoodVolume));
                    }

                    Future.microtask(() {
                      BlocProvider.of<SqfliteBloc>(context).add(SqfliteInsert(
                          verifiedTruckEntity: verifiedTruckEntity));
                      BlocProvider.of<DetectingBloc>(context)
                          .add(StopDetectingEvent());
                      SnackBar snackBar = SnackBar(
                        content: Text(
                            'Truck with license plate ${widget.licensePlateText} and $estimatedVolume has been verified. You can find it in the verified trucks section.'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    });
                  }
                },
              ),
            ),
            const SizedBox(
              height: 40,
            ),
          ],
        )
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
    if (_detector != null) _detector?.stop();
    _subscription?.cancel();
    super.dispose();
  }
}
