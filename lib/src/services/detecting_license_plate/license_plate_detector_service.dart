// Copyright 2023 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:forest_guard/src/models/recognition_model.dart';
import 'package:forest_guard/src/utils/image_utils.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

enum _Codes {
  init,
  busy,
  ready,
  detect,
  result,
}

/// A command sent between [LicensePlateDetector] and [_DetectorServer].
class _Command {
  const _Command(this.code, {this.args});

  final _Codes code;
  final List<Object>? args;
}

/// A Simple Detector that handles object detection via Service
///
/// All the heavy operations like pre-processing, detection, ets,
/// are executed in a background isolate.
/// This class just sends and receives messages to the isolate.
///Input Tensor
///
/// Name: serving_default_input:0
/// Index: 0
/// Shape: [1, 3, 224, 224]
/// Shape Signature: [1, 3, 224, 224]
/// Data Type: numpy.float32
/// Quantization: (0.0, 0)
/// Quantization Parameters:
/// Scales: Empty
/// Zero Points: Empty
/// Quantized Dimension: 0
/// Sparsity Parameters: {}
///
///
/// Output Tensor 1
/// Name: PartitionedCall:1
/// Index: 995
/// Shape: [1, 1029, 4]
/// Shape Signature: [1, 1029, 4]
/// Data Type: numpy.float32
/// Quantization: (0.0, 0)
/// Quantization Parameters: Empty
/// Sparsity Parameters: {}
///
///
/// Output Tensor 2
/// Name: PartitionedCall:0
/// Index: 991
/// Shape: [1, 1029, 1]
/// Shape Signature: [1, 1029, 1]
/// Data Type: numpy.float32
/// Quantization: (0.0, 0)
/// Quantization Parameters: Empty
/// Sparsity Parameters: {}
///
///

class LicensePlateDetector {
  static const String _modelPath =
      'assets/models/license_plate/best_float32.tflite';
  static const String _labelPath = 'assets/models/license_plate/labelmap.txt';

  LicensePlateDetector._(this._isolate, this._interpreter, this._labels);

  final Isolate _isolate;
  late final Interpreter _interpreter;
  late final List<String> _labels;

  // To be used by detector (from UI) to send message to our Service ReceivePort
  late final SendPort _sendPort;
  bool _isReady = false;

  final StreamController<Map<String, dynamic>> resultsStream =
      StreamController<Map<String, dynamic>>();

  /// Open the database at [path] and launch the server on a background isolate..
  static Future<LicensePlateDetector> start() async {
    final ReceivePort receivePort = ReceivePort();
    // sendPort - To be used by service Isolate to send message to our ReceiverPort
    final Isolate isolate =
        await Isolate.spawn(_DetectorServer._run, receivePort.sendPort);

    final LicensePlateDetector result = LicensePlateDetector._(
      isolate,
      await _loadModel(),
      await _loadLabels(),
    );
    receivePort.listen((message) {
      result._handleCommand(message as _Command);
    });
    return result;
  }

  static Future<Interpreter> _loadModel() async {
    final interpreterOptions = InterpreterOptions();

    // Use XNNPACK Delegate
    if (Platform.isAndroid) {
      interpreterOptions.addDelegate(XNNPackDelegate());
    }

    return Interpreter.fromAsset(
      _modelPath,
      options: interpreterOptions..threads = 4,
    );
  }

  static Future<List<String>> _loadLabels() async {
    return (await rootBundle.loadString(_labelPath)).split('\n');
  }

  /// Starts CameraImage processing
  void processFrame(CameraImage cameraImage) {
    if (_isReady) {
      _sendPort.send(_Command(_Codes.detect, args: [cameraImage]));
    }
  }

  /// Handler invoked when a message is received from the port communicating
  /// with the database server.
  void _handleCommand(_Command command) {
    switch (command.code) {
      case _Codes.init:
        _sendPort = command.args?[0] as SendPort;
        // ----------------------------------------------------------------------
        // Before using platform channels and plugins from background isolates we
        // need to register it with its root isolate. This is achieved by
        // acquiring a [RootIsolateToken] which the background isolate uses to
        // invoke [BackgroundIsolateBinaryMessenger.ensureInitialized].
        // ----------------------------------------------------------------------
        RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
        _sendPort.send(_Command(_Codes.init, args: [
          rootIsolateToken,
          _interpreter.address,
          _labels,
        ]));
      case _Codes.ready:
        _isReady = true;
      case _Codes.busy:
        _isReady = false;
      case _Codes.result:
        _isReady = true;
        resultsStream.add(command.args?[0] as Map<String, dynamic>);
      default:
        debugPrint('Detector unrecognized command: ${command.code}');
    }
  }

  /// Kills the background isolate and its detector server.
  void stop() {
    _isolate.kill();
  }
}

/// The portion of the [LicensePlateDetector] that runs on the background isolate.
///
/// This is where we use the new feature Background Isolate Channels, which
/// allows us to use plugins from background isolates.
class _DetectorServer {
  /// Input size of image (height = width = 244)
  static const int mlModelInputSize = 640;

  /// Result confidence threshold
  static const double confidence = 0.5;
  Interpreter? _interpreter;
  _DetectorServer(this._sendPort);

  final SendPort _sendPort;

  // ----------------------------------------------------------------------
  // Here the plugin is used from the background isolate.
  // ----------------------------------------------------------------------

  /// The main entrypoint for the background isolate sent to [Isolate.spawn].
  static void _run(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    final _DetectorServer server = _DetectorServer(sendPort);
    receivePort.listen((message) async {
      final _Command command = message as _Command;
      await server._handleCommand(command);
    });
    // receivePort.sendPort - used by UI isolate to send commands to the service receiverPort
    sendPort.send(_Command(_Codes.init, args: [receivePort.sendPort]));
  }

  /// Handle the [command] received from the [ReceivePort].
  Future<void> _handleCommand(_Command command) async {
    switch (command.code) {
      case _Codes.init:
        // ----------------------------------------------------------------------
        // The [RootIsolateToken] is required for
        // [BackgroundIsolateBinaryMessenger.ensureInitialized] and must be
        // obtained on the root isolate and passed into the background isolate via
        // a [SendPort].
        // ----------------------------------------------------------------------
        RootIsolateToken rootIsolateToken =
            command.args?[0] as RootIsolateToken;
        // ----------------------------------------------------------------------
        // [BackgroundIsolateBinaryMessenger.ensureInitialized] for each
        // background isolate that will use plugins. This sets up the
        // [BinaryMessenger] that the Platform Channels will communicate with on
        // the background isolate.
        // ----------------------------------------------------------------------
        BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
        _interpreter = Interpreter.fromAddress(command.args?[1] as int);
        _sendPort.send(const _Command(_Codes.ready));
      case _Codes.detect:
        _sendPort.send(const _Command(_Codes.busy));
        _convertCameraImage(command.args?[0] as CameraImage);
      default:
        debugPrint('_DetectorService unrecognized command ${command.code}');
    }
  }

  void _convertCameraImage(CameraImage cameraImage) {
    var preConversionTime = DateTime.now().millisecondsSinceEpoch;

    convertCameraImageToImage(cameraImage).then((image) {
      if (image != null) {
        if (Platform.isAndroid) {
          image = image_lib.copyRotate(image, angle: 90);
        }

        final results = analyseImage(image, preConversionTime);
        _sendPort.send(_Command(_Codes.result, args: [results, image]));
      }
    });
  }

  Map<String, dynamic> analyseImage(
      image_lib.Image? image, int preConversionTime) {
    // var conversionElapsedTime =
    //     DateTime.now().millisecondsSinceEpoch - preConversionTime;

    //!Pre
    /// Pre-process the image
    /// Resizing image for model [244, 244]
    List<List<List<List<double>>>> imageMatrix = preProcessing(image);

    //var inferenceTimeStart = DateTime.now().millisecondsSinceEpoch;
    //! Inference
    final output = _runInference(imageMatrix);
    //!Post
    List<RecognitionModel> recognitions = postProcessing(output);

    return {"recognitions": recognitions, 'image': image};
  }

  List<RecognitionModel> postProcessing(List<List<List<List<double>>>> output) {
    // Assuming the 5 values are [top, left, bottom, right, score]
    final List<Rect> locations = [];
    final List<double> scores = [];
    for (var i = 0; i < 8400; i++) {
      var left = output[0][0][0][i];
      var top = output[0][0][1][i];
      final right = output[0][0][2][i];
      final bottom = output[0][0][3][i];
      final score = output[0][0][4][i];

      left = left - (right / 2);
      top = top - (bottom / 2);
      if (score > confidence) {
        final newLocation = Rect.fromLTWH(left, top, right, bottom);

        // Check if there's an existing location that is close to the new location
        final isCloseToExisting = locations.any((existingLocation) {
          final distance = sqrt(
              pow(existingLocation.center.dx - newLocation.center.dx, 2) +
                  pow(existingLocation.center.dy - newLocation.center.dy, 2));

          // Change this value to adjust the definition of "close"
          const maxDistance = 0.05; // Adjust this value as needed

          return distance < maxDistance;
        });

        if (!isCloseToExisting) {
          locations.add(newLocation);
          scores.add(score);
        }
      }
    }
    // Number of  detections
    final numberOfDetections = locations.length;
    // Assuming all detections are of the same class
    final classes = List.filled(numberOfDetections, 0);
    // final List<String> classification =
    //     List.filled(numberOfDetections, _labels![0]);

    // Create RecognitionModel objects
    final recognitions = List<RecognitionModel>.generate(
      numberOfDetections,
      //       RecognitionModel(i, label, score, locations[i]),
      (i) =>
          RecognitionModel(i, classes[i].toString(), scores[i], locations[i]),
    );
    return recognitions;
  }

  List<List<List<List<double>>>> preProcessing(image_lib.Image? image) {
    /// Pre-process the image
    /// Resizing image for model [244, 244]
    final imageInput = image_lib.copyResize(
      image!,
      width: mlModelInputSize,
      height: mlModelInputSize,
    );
    final imageMatrix = List.generate(
      1,
      (_) => List.generate(
        imageInput.height,
        (y) => List.generate(
          imageInput.width,
          (x) => List.generate(
            3,
            (channel) {
              final pixel = imageInput.getPixel(x, y);
              switch (channel) {
                case 0:
                  return pixel.r / 255.0;
                case 1:
                  return pixel.g / 255.0;
                case 2:
                  return pixel.b / 255.0;
                default:
                  throw ArgumentError('Invalid channel index: $channel');
              }
            },
          ),
        ),
      ),
    );

    return imageMatrix;
  }

  List<List<List<List<double>>>> _runInference(
    List<List<List<List<double>>>> imageMatrix,
  ) {
    /// Object detection main function
    // Set output tensor
    final output = {
      0: List.generate(
          1, (_) => List.generate(5, (_) => List.filled(8400, 0.0)))
    };
    _interpreter!.runForMultipleInputs([imageMatrix], output);

    return output.values.toList();
    // }
  }
}
