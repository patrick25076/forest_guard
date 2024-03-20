/// `VerifiedTruckEntity` is a data class that represents a verified truck.
///
/// It contains information about a truck that has been verified, including
/// the license plate, timestamp of verification, estimated volume of wood
/// the truck is carrying, and the legal volume of wood that the truck is
/// allowed to carry.
///
/// The class provides methods to convert the object to a map with the `toMap` method,
/// and to create an object from a map with the `fromMap` factory constructor.
///
/// The `toString` method is overridden to provide a string representation of the object.
class VerifiedTruckEntity {
  late String id;
  final String licensePlate;
  final DateTime timestamp;
  final double estimatedWoodVolume;
  final double legalWoodVolume;

  VerifiedTruckEntity({
    required this.licensePlate,
    required this.timestamp,
    required this.estimatedWoodVolume,
    required this.legalWoodVolume,
  });

  Map<String, dynamic> toMap() {
    return {
      'licensePlate': licensePlate,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'estimatedWoodVolume': estimatedWoodVolume,
      'legalWoodVolume': legalWoodVolume,
    };
  }

  factory VerifiedTruckEntity.fromMap(Map<String, dynamic> map) {
    return VerifiedTruckEntity(
      licensePlate: map['licensePlate'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      estimatedWoodVolume: map['estimatedWoodVolume'],
      legalWoodVolume: map['legalWoodVolume'],
    );
  }

  @override
  String toString() {
    return 'VerifiedTruckEntity{licensePlate: $licensePlate, timestamp: $timestamp, estimatedWoodVolume: $estimatedWoodVolume, legalWoodVolume: $legalWoodVolume}';
  }
}
