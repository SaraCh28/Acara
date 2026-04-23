class CheckoutDraftModel {
  final String eventId;
  final int regularCount;
  final int vipCount;
  final double regularPrice;
  final double vipPrice;
  final String? bookerName;
  final String? bookerEmail;
  final String? bookerPhone;

  const CheckoutDraftModel({
    required this.eventId,
    required this.regularCount,
    required this.vipCount,
    required this.regularPrice,
    required this.vipPrice,
    this.bookerName,
    this.bookerEmail,
    this.bookerPhone,
  });

  int get totalTickets => regularCount + vipCount;

  double get totalPrice =>
      (regularCount * regularPrice) + (vipCount * vipPrice);

  String get summaryLabel {
    final segments = <String>[];
    if (vipCount > 0) {
      segments.add('$vipCount VIP');
    }
    if (regularCount > 0) {
      segments.add('$regularCount Regular');
    }
    return segments.join(' • ');
  }

  CheckoutDraftModel copyWith({
    String? eventId,
    int? regularCount,
    int? vipCount,
    double? regularPrice,
    double? vipPrice,
    String? bookerName,
    String? bookerEmail,
    String? bookerPhone,
  }) {
    return CheckoutDraftModel(
      eventId: eventId ?? this.eventId,
      regularCount: regularCount ?? this.regularCount,
      vipCount: vipCount ?? this.vipCount,
      regularPrice: regularPrice ?? this.regularPrice,
      vipPrice: vipPrice ?? this.vipPrice,
      bookerName: bookerName ?? this.bookerName,
      bookerEmail: bookerEmail ?? this.bookerEmail,
      bookerPhone: bookerPhone ?? this.bookerPhone,
    );
  }
}
