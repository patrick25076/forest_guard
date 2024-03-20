import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forest_guard/src/bloc/bloc/sqflite_bloc/sqflite_bloc.dart';

class VerifiedTrucksView extends StatelessWidget {
  const VerifiedTrucksView({super.key});

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<SqfliteBloc>(context).add(SqfliteGetAll());

    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(0, 0, 0, 0.9),
        child: Column(
          children: [
            Expanded(
              child: Center(child: BlocBuilder<SqfliteBloc, SqfliteState>(
                builder: (context, state) {
                  if (state is SqfliteInitial) {
                    return const Text('Initial');
                  } else if (state is SqfliteLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is SqfliteLoaded) {
                    return ListView.builder(
                      itemCount: state.data.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: GestureDetector(
                            onTap: () {
                              _showWoodDialog(context, state, index);
                            },
                            child:
                                VerifiedTruckWidget(state: state, index: index),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Text('Error');
                  }
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _showWoodDialog(
      BuildContext context, SqfliteLoaded state, int index) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.info),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Nr. Identificare Mijloc Transporti: ${state.data[index].licensePlate.replaceAll('/', '')}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Valabilitate: ${state.data[index].timestamp.toString().substring(0, 19)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Volum Legal (mc): ${state.data[index].legalWoodVolume.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Volum Estimativ (mc): ${state.data[index].estimatedWoodVolume.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class VerifiedTruckWidget extends StatelessWidget {
  final SqfliteLoaded state;
  final int index;
  const VerifiedTruckWidget({
    super.key,
    required this.state,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      child: GestureDetector(
        onLongPress: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Delete'),
                  content:
                      const Text('Are you sure you want to delete this entry?'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          BlocProvider.of<SqfliteBloc>(context).add(
                              SqfliteDeleteByLicensePlate(
                                  state.data[index].licensePlate));
                          Navigator.pop(context);
                        },
                        child: const Text('Yes')),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('No')),
                  ],
                );
              });
        },
        child: ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Center(
              child: Text(
            state.data[index].licensePlate.replaceAll('/', ' '),
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          )),
        ),
      ),
    );
  }
}
