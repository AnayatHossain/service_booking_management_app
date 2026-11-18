import 'dart:async';

class BookingStatusEvent {
  final String bookingId;
  final String newStatus;

  BookingStatusEvent({
    required this.bookingId,
    required this.newStatus,
  });
}

class BookingRatedEvent {
  final String bookingId;
  final double rating;
  final String? review;
  final bool isDeleted;

  BookingRatedEvent({
    required this.bookingId,
    required this.rating,
    this.review,
    this.isDeleted = false,
  });
}

class BookingEventBus {
  static final StreamController<BookingStatusEvent> _statusController =
      StreamController<BookingStatusEvent>.broadcast();

  static final StreamController<BookingRatedEvent> _ratedController =
      StreamController<BookingRatedEvent>.broadcast();

  static Stream<BookingStatusEvent> get stream => _statusController.stream;
  static Stream<BookingRatedEvent> get ratedStream => _ratedController.stream;

  static void notifyStatusChanged({
    required String bookingId,
    required String newStatus,
  }) {
    if (!_statusController.isClosed) {
      _statusController.add(BookingStatusEvent(
        bookingId: bookingId,
        newStatus: newStatus,
      ));
    }
  }

  static void notifyBookingRated({
    required String bookingId,
    required double rating,
    String? review,
  }) {
    if (!_ratedController.isClosed) {
      _ratedController.add(BookingRatedEvent(
        bookingId: bookingId,
        rating: rating,
        review: review,
        isDeleted: false,
      ));
    }
  }

  static void notifyBookingRatingDeleted({
    required String bookingId,
  }) {
    if (!_ratedController.isClosed) {
      _ratedController.add(BookingRatedEvent(
        bookingId: bookingId,
        rating: 0,
        review: null,
        isDeleted: true,
      ));
    }
  }
}
