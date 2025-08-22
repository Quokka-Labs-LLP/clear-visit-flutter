import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String? id;
  final String name;
  final String specialization;
  final String? location;
  final String patientId;
  final Timestamp createdAt;

  DoctorModel({
    this.id,
    required this.name,
    required this.specialization,
    this.location,
    required this.patientId,
    required this.createdAt,
  });

  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DoctorModel(
      id: doc.id,
      name: data['name'] ?? '',
      specialization: data['specialization'] ?? '',
      location: data['location'],
      patientId: data['patientId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'specialization': specialization,
      'location': location,
      'patientId': patientId,
      'createdAt': createdAt,
    };
  }

  DoctorModel copyWith({
    String? id,
    String? name,
    String? specialization,
    String? location,
    String? patientId,
    Timestamp? createdAt,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      location: location,
      patientId: patientId ?? this.patientId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'DoctorModel(id: $id, name: $name, specialization: $specialization, location: $location, patientId: $patientId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoctorModel &&
        other.id == id &&
        other.name == name &&
        other.specialization == specialization &&
        other.location == location &&
        other.patientId == patientId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        specialization.hashCode ^
        location.hashCode ^
        patientId.hashCode ^
        createdAt.hashCode;
  }
}
