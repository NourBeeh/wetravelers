import 'package:wetravellers/core/domain/models/offers/flight_offer.dart';
import 'package:wetravellers/core/domain/models/offers/hotel_offer.dart';
import 'package:wetravellers/core/domain/models/offers/car_offer.dart';

abstract class Filter<T> {
  List<T> apply(List<T> items);
}

class PriceRangeFilter<T> extends Filter<T> {
  final double? min;
  final double? max;
  PriceRangeFilter({this.min, this.max});
  @override
  List<T> apply(List<T> items) {
    return items.where((e) {
      final price = (e as dynamic).price as double;
      if (min != null && price < min!) return false;
      if (max != null && price > max!) return false;
      return true;
    }).toList();
  }
}

class FlightStopsFilter extends Filter<FlightOffer> {
  final int? maxStops;
  FlightStopsFilter(this.maxStops);
  @override
  List<FlightOffer> apply(List<FlightOffer> items) {
    if (maxStops == null) return items;
    return items.where((e) => (e.stops ?? 0) <= maxStops!).toList();
  }
}

class HotelRatingFilter extends Filter<HotelOffer> {
  final double minRating;
  HotelRatingFilter(this.minRating);
  @override
  List<HotelOffer> apply(List<HotelOffer> items) {
    return items.where((e) => (e.rating ?? 0) >= minRating).toList();
  }
}

class CarSeatsFilter extends Filter<CarOffer> {
  final int minSeats;
  CarSeatsFilter(this.minSeats);
  @override
  List<CarOffer> apply(List<CarOffer> items) {
    return items.where((e) => (e.seats ?? 0) >= minSeats).toList();
  }
}

class CompositeFilter<T> extends Filter<T> {
  final List<Filter<T>> filters;
  CompositeFilter(this.filters);
  @override
  List<T> apply(List<T> items) {
    var result = items;
    for (final f in filters) {
      result = f.apply(result);
    }
    return result;
  }
}
