import 'package:flutter/material.dart';
import 'package:forest_guard/src/ui/home_view/widgets/create_test_data.dart';

//!Deprecated
class LowerButtonsWidget extends StatelessWidget {
  const LowerButtonsWidget({
    super.key,
    required this.colorScheme,
  });

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(0, 0, 0, 0.9),
      height: 200,
      child: Row(children: [
        const Spacer(),
        ElevatedButton(
            onLongPress: () {
              //opens a dialog
              showDialog(
                  context: context,
                  builder: (contxt) {
                    return const CreateTestData();
                  });
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    10), // Adjust the corner radius as needed
              ),
              minimumSize: const Size(100, 100),
              padding: const EdgeInsets.all(15),
              backgroundColor: colorScheme.primary,
            ),
            onPressed: () {
              Navigator.pushNamed(context, 'verified_trucks');
            },
            child:
                Icon(Icons.fire_truck, color: colorScheme.onPrimary, size: 50)),
        const Spacer(),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 100),
              padding: const EdgeInsets.all(15),
              backgroundColor: colorScheme.primary,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
            child: Icon(
              Icons.camera_alt,
              color: colorScheme.onPrimary,
              size: 50,
            )),
        const Spacer(),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                // Adjust the corner radius as needed
              ),
              minimumSize: const Size(100, 100),
              padding: const EdgeInsets.all(15),
              backgroundColor: colorScheme.primary,
            ),
            onPressed: () {},
            child: Text(
              '112',
              style: TextStyle(color: colorScheme.onPrimary, fontSize: 35),
            )),
        const Spacer(),
      ]),
    );
  }
}
