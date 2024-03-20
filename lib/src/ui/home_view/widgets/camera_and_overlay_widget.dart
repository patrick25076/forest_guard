import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forest_guard/src/bloc/bloc/detecting_bloc/detecting_bloc.dart';
import 'package:forest_guard/src/bloc/bloc/is_detecting_cubit/is_detecting.dart';
import 'package:forest_guard/src/ui/home_view/widgets/detecting_license_plate/detecting_license_plate_widget.dart';
import 'package:forest_guard/src/ui/home_view/widgets/detecting_log/detecting_log_widget.dart';
import 'package:image_picker/image_picker.dart';

class CameraAndOverlayWidget extends StatefulWidget {
  const CameraAndOverlayWidget({
    super.key,
    required this.colorScheme,
  });

  final ColorScheme colorScheme;

  @override
  State<CameraAndOverlayWidget> createState() => _CameraAndOverlayWidgetState();
}

class _CameraAndOverlayWidgetState extends State<CameraAndOverlayWidget> {
  // give this state a key
  bool cameraOnOff = false;
  bool isDetecting = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        // If _initializeControllerFuture is null, show a loading indicator.
        // Otherwise, use a FutureBuilder to either show the camera preview
        // if the controller is initialized, or a loading indicator if not.
        children: [
          BlocBuilder<DetectingBloc, DetectingBlocState>(
            builder: (context, state) {
              if (state is DetectingBlocInitial) {
                BlocProvider.of<IsDetectingCubit>(context).stopDetecting();
                return Stack(children: [
                  Container(
                    color: Colors.black,
                  ),
                  Column(
                    children: [
                      const Spacer(),
                      Center(
                        child: IconButton(
                            icon: Icon(Icons.play_arrow,
                                color: widget.colorScheme.onPrimary, size: 90),
                            onPressed: () {
                              BlocProvider.of<DetectingBloc>(context)
                                  .add(StartDetectingEvent());
                            }),
                      ),
                    ],
                  ),
                ]);
              } else if (state is DetecingLicensePlateSuccessState) {
                cameraOnOff = false;
                return Container(
                  color: Colors.black,
                );
              } else if (state is DetectingLicensePlate) {
                try {
                  if (state.snackbar != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (state.snackbar != null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(state.snackbar!);
                      }
                    });
                  }
                  return const LicensePlateDetectorWidget();
                } catch (e) {
                  throw Exception(e);
                }
              } else if (state is DetectingLoading) {
                return const CircularProgressIndicator();
              } else if (state is DetectingLog) {
                return LogDetectorWidget(
                    ratio: state.ratio,
                    licensePlateText: state.licensePlateText,
                    legalWoodVolume: state.legalWoodVolume);
              } else {
                return const Text('Error');
              }
            },
          ),
          Column(
            children: [
              Container(
                color: Colors.grey.withOpacity(0.6),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (contxt) {
                                return AlertDialog(
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('close',
                                            style: TextStyle(
                                                color: Colors.green))),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, 'create_test_data_view');
                                        },
                                        child: const Text('create test data',
                                            style: TextStyle(
                                                color: Colors.green))),
                                  ],
                                  title: const Text('Help'),
                                  content: const Text(
                                      'This is the help dialog. It will be filled with useful information in the future.'),
                                );
                              });
                        },
                        icon: Icon(
                          Icons.question_mark,
                          color: widget.colorScheme.onPrimary,
                          size: 30,
                        )),
                    const Spacer(),
                    BlocBuilder<DetectingBloc, DetectingBlocState>(
                        builder: (context, state) {
                      if (state is! DetectingBlocInitial) {
                        return IconButton(
                            onPressed: () {
                              BlocProvider.of<DetectingBloc>(context)
                                  .add(StopDetectingEvent());
                            },
                            icon: Icon(Icons.stop,
                                color: widget.colorScheme.onPrimary, size: 30));
                      }
                      return const SizedBox.shrink();
                    }),
                    const Spacer(),
                    IconButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          picker.pickImage(source: ImageSource.gallery);
                        },
                        icon: Icon(Icons.photo,
                            color: widget.colorScheme.onPrimary, size: 30)),
                  ],
                ),
              ),
              const Spacer(),
              BlocListener<IsDetectingCubit, IsDetectingState>(
                listener: (BuildContext context, state) {
                  if (state is Isdetecting) {
                    setState(() {
                      isDetecting = true;
                    });
                  } else if (state is IsNotDetecting) {
                    setState(() {
                      isDetecting = false;
                    });
                  }
                },
                child: Visibility(
                  visible: isDetecting,
                  child: Container(
                    color: Colors.grey.withOpacity(0.6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Detecting!',
                            style: TextStyle(
                                fontSize: 20,
                                color: widget.colorScheme.onPrimary)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
