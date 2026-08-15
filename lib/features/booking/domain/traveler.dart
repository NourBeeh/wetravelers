import 'package:flutter/foundation.dart';

@immutable
class Traveler {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final String? nationality;
  final String? documentNumber;
  final String? documentType;
  final String email;
  final String phone;

  const Traveler({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    this.nationality,
    this.documentNumber,
    this.documentType,
    required this.email,
    required this.phone,
  });
}

@immutable
class BookingContact {
  final String email;
  final String phone;
  final String firstName;
  final String lastName;

  const BookingContact({
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
  });
}
