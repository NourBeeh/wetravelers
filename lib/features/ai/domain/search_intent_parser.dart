/// Parser that extracts search intent from natural language user queries
/// Supports both English and Arabic queries for flights, hotels, and car rentals
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Result of parsing a search intent
class ParsedSearchIntent {
  final String? service; // 'flight', 'hotel', 'car', or null if unknown
  final String? origin;
  final String? destination;
  final DateTime? date;
  final DateTime? returnDate;
  final int? passengers;

  const ParsedSearchIntent({
    this.service,
    this.origin,
    this.destination,
    this.date,
    this.returnDate,
    this.passengers,
  });

  bool get isValid => service != null;
}

class SearchIntentParser {
  // Common date formats to try parsing
  static final _dateFormats = [
    'dd MMMM yyyy',
    'dd/MM/yyyy',
    'MM/dd/yyyy',
    'yyyy-MM-dd',
    'd MMM yyyy',
  ];

  // Service keywords in multiple languages
  static const _flightKeywords = {'flight', 'flights', 'طائرة', 'رحلة طيران', 'طيران'};
  static const _hotelKeywords = {'hotel', 'hotels', 'فندق', 'فنادق'};
  static const _carKeywords = {'car', 'cars', 'rent a car', 'سيارة', 'إيجار سيارة'};

  // Origin/destination indicators
  static const _fromKeywords = {'from', 'من'};
  static const _toKeywords = {'to', 'إلى', 'الى'};

  /// Parse a natural language query into a structured search intent
  static ParsedSearchIntent parse(String query) {
    final lowerQuery = query.toLowerCase();
    String? service = _detectService(lowerQuery);
    
    if (service == null) {
      return const ParsedSearchIntent();
    }

    // Extract origin and destination
    final locations = _extractLocations(lowerQuery);
    final origin = locations.$1;
    final destination = locations.$2;

    // Extract dates
    final dates = _extractDates(query);
    final date = dates.$1;
    final returnDate = dates.$2;

    // Extract number of passengers/guests
    final passengers = _extractPassengers(lowerQuery);

    return ParsedSearchIntent(
      service: service,
      origin: origin,
      destination: destination,
      date: date,
      returnDate: returnDate,
      passengers: passengers,
    );
  }

  static String? _detectService(String lowerQuery) {
    if (_flightKeywords.any((keyword) => lowerQuery.contains(keyword))) return 'flight';
    if (_hotelKeywords.any((keyword) => lowerQuery.contains(keyword))) return 'hotel';
    if (_carKeywords.any((keyword) => lowerQuery.contains(keyword))) return 'car';
    return null;
  }

  static (String?, String?) _extractLocations(String lowerQuery) {
    String? origin;
    String? destination;

    // Split query to find from-to pattern
    for (final fromKeyword in _fromKeywords) {
      if (lowerQuery.contains(fromKeyword)) {
        final afterFrom = lowerQuery.split(fromKeyword).last.trim();
        for (final toKeyword in _toKeywords) {
          if (afterFrom.contains(toKeyword)) {
            final parts = afterFrom.split(toKeyword);
            origin = parts.first.trim();
            destination = parts.last.trim();
            return (origin, destination);
          }
        }
        // If no "to" found, take what's after from as origin
        origin = afterFrom.split(' ').take(2).join(' ').trim();
      }
    }

    return (origin, destination);
  }

  static (DateTime?, DateTime?) _extractDates(String query) {
    DateTime? departureDate;
    DateTime? returnDate;

    // Look for date patterns in the query
    for (final format in _dateFormats) {
      try {
        final formatter = DateFormat(format);
        // Simple pattern match - in production this would be more sophisticated
        final words = query.split(' ');
        for (int i = 0; i < words.length - 2; i++) {
          final candidate = '${words[i]} ${words[i+1]} ${words[i+2]}';
          try {
            final date = formatter.parseLoose(candidate);
            if (departureDate == null) {
              departureDate = date;
            } else {
              returnDate = date;
              break;
            }
          } catch (_) {
            // Skip invalid dates
          }
        }
      } catch (_) {
        continue;
      }
    }

    return (departureDate, returnDate);
  }

  static int? _extractPassengers(String lowerQuery) {
    final passengerPatterns = [
      RegExp(r'(\d+) passenger'),
      RegExp(r'(\d+) adult'),
      RegExp(r'لـ\s*(\d+)\s*أشخاص'),
      RegExp(r'for\s*(\d+)\s*people'),
    ];

    for (final pattern in passengerPatterns) {
      final match = pattern.firstMatch(lowerQuery);
      if (match != null) {
        return int.tryParse(match.group(1)!);
      }
    }

    return null;
  }
}