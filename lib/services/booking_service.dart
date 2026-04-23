import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/booking_model.dart';
import 'auth_service.dart';

final bookingServiceProvider = Provider<BookingService>((ref) {
  return BookingService();
});

// A provider holding the list of user bookings
final userBookingsProvider =
    NotifierProvider<UserBookingsNotifier, List<BookingModel>>(() {
      return UserBookingsNotifier();
    });

class UserBookingsNotifier extends Notifier<List<BookingModel>> {
  final _supabase = Supabase.instance.client;

  @override
  List<BookingModel> build() {
    // Listen to auth changes and fetch bookings
    ref.listen(currentUserProvider, (previous, next) {
      if (next != null) {
        fetchBookings(next.id);
      } else {
        state = [];
      }
    });

    // Initial fetch if already logged in
    final user = ref.read(currentUserProvider);
    if (user != null) {
      fetchBookings(user.id);
    }

    return [];
  }

  final _uuid = const Uuid();

  Future<void> fetchBookings(String userId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final bookings = (response as List<dynamic>)
          .map((data) => BookingModel.fromMap(data as Map<String, dynamic>))
          .toList();

      state = bookings;
    } catch (e) {
      // Handle error
    }
  }

  Future<BookingModel> bookEvent({
    required String userId,
    required String eventId,
    required int regularTicketCount,
    required int vipTicketCount,
    required double totalPrice,
    required String paymentMethodId,
    required String bookerName,
    required String bookerEmail,
    required String bookerPhone,
  }) async {
    final ticketCount = regularTicketCount + vipTicketCount;
    final newBooking = BookingModel(
      id: _uuid.v4(),
      userId: userId,
      eventId: eventId,
      ticketCount: ticketCount,
      regularTicketCount: regularTicketCount,
      vipTicketCount: vipTicketCount,
      totalPrice: totalPrice,
      paymentMethodId: paymentMethodId,
      ticketCode:
          'ACARA-${eventId.toUpperCase()}-${_uuid.v4().substring(0, 8).toUpperCase()}',
      status: 'confirmed',
      bookerName: bookerName,
      bookerEmail: bookerEmail,
      bookerPhone: bookerPhone,
      createdAt: DateTime.now(),
    );

    await _supabase.from('bookings').insert(newBooking.toMap());

    state = [newBooking, ...state];
    return newBooking;
  }

  Future<void> cancelBooking(String bookingId) async {
    await _supabase
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId);

    state = state
        .map(
          (booking) => booking.id == bookingId
              ? booking.copyWith(status: 'cancelled')
              : booking,
        )
        .toList();
  }

  BookingModel? findById(String bookingId) {
    for (final booking in state) {
      if (booking.id == bookingId) {
        return booking;
      }
    }
    return null;
  }
}

class BookingService {
  // Service logic can go here if needed outside the StateNotifier
}
