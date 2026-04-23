class BookingModel {
  final String id;
  final String userId;
  final String eventId;
  final int ticketCount;
  final int regularTicketCount;
  final int vipTicketCount;
  final double totalPrice;
  final String paymentMethodId;
  final String ticketCode;
  final String status; // 'confirmed', 'cancelled', 'pending'
  final String bookerName;
  final String bookerEmail;
  final String bookerPhone;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.ticketCount,
    required this.regularTicketCount,
    required this.vipTicketCount,
    required this.totalPrice,
    required this.paymentMethodId,
    required this.ticketCode,
    required this.status,
    required this.bookerName,
    required this.bookerEmail,
    required this.bookerPhone,
    required this.createdAt,
  });

  BookingModel copyWith({
    String? id,
    String? userId,
    String? eventId,
    int? ticketCount,
    int? regularTicketCount,
    int? vipTicketCount,
    double? totalPrice,
    String? paymentMethodId,
    String? ticketCode,
    String? status,
    String? bookerName,
    String? bookerEmail,
    String? bookerPhone,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      ticketCount: ticketCount ?? this.ticketCount,
      regularTicketCount: regularTicketCount ?? this.regularTicketCount,
      vipTicketCount: vipTicketCount ?? this.vipTicketCount,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      ticketCode: ticketCode ?? this.ticketCode,
      status: status ?? this.status,
      bookerName: bookerName ?? this.bookerName,
      bookerEmail: bookerEmail ?? this.bookerEmail,
      bookerPhone: bookerPhone ?? this.bookerPhone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'ticket_count': ticketCount,
      'regular_ticket_count': regularTicketCount,
      'vip_ticket_count': vipTicketCount,
      'total_price': totalPrice,
      'payment_method_id': paymentMethodId,
      'ticket_code': ticketCode,
      'status': status,
      'booker_name': bookerName,
      'booker_email': bookerEmail,
      'booker_phone': bookerPhone,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      eventId: map['event_id'] as String,
      ticketCount: map['ticket_count'] as int,
      regularTicketCount: map['regular_ticket_count'] as int,
      vipTicketCount: map['vip_ticket_count'] as int,
      totalPrice: (map['total_price'] as num).toDouble(),
      paymentMethodId: map['payment_method_id'] as String,
      ticketCode: map['ticket_code'] as String,
      status: map['status'] as String,
      bookerName: map['booker_name'] as String? ?? '',
      bookerEmail: map['booker_email'] as String? ?? '',
      bookerPhone: map['booker_phone'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
