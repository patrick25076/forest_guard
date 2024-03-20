import 'package:flutter/material.dart';
import 'package:forest_guard/injection.dart';
import 'package:forest_guard/src/bloc/bloc/sqflite_bloc/sqflite_bloc.dart';
import 'package:forest_guard/src/entitys/verified_truck_entity.dart';

//TODO: remove this class before release
//!ROMOVE THIS CLASS BEFORE RELEASE
//!
//!TEST ONLY
class CreateTestData extends StatelessWidget {
  const CreateTestData({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController licensePlateController = TextEditingController();
    TextEditingController legalWoodVolumeController = TextEditingController();
    TextEditingController estimatedWoodVolumeController =
        TextEditingController();

    return Dialog(
      child: SizedBox(
        height: 200,
        width: 200,
        child: Column(
          children: [
            const Text('Create Test Data'),
            Expanded(
              child: TextField(
                controller: licensePlateController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'license plate',
                ),
              ),
            ),
            //NOTE: this is a test only
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                controller: legalWoodVolumeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'legal wood volume',
                ),
              ),
            ),
            //NOTE: this is a test only

            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                controller: estimatedWoodVolumeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'estimated wood volume',
                ),
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      sl<SqfliteBloc>().add(SqfliteDeleteAll());
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Remove All',
                      style: TextStyle(color: Colors.red),
                    )),
                ElevatedButton(
                    onPressed: () {
                      if (estimatedWoodVolumeController.text.isEmpty) {
                        estimatedWoodVolumeController.text = '0';
                      }
                      if (legalWoodVolumeController.text.isEmpty) {
                        legalWoodVolumeController.text = '0';
                      }

                      sl<SqfliteBloc>().add(
                        SqfliteInsert(
                          verifiedTruckEntity: VerifiedTruckEntity(
                              licensePlate: licensePlateController.text,
                              timestamp: DateTime.now(),
                              estimatedWoodVolume: double.parse(
                                  estimatedWoodVolumeController.text),
                              legalWoodVolume:
                                  double.parse(legalWoodVolumeController.text)),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Create')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
