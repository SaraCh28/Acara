class PaymentMethodModel {
  final String id;
  final String brand;
  final String holderName;
  final String last4;
  final String expiry;

  const PaymentMethodModel({
    required this.id,
    required this.brand,
    required this.holderName,
    required this.last4,
    required this.expiry,
  });

  PaymentMethodModel copyWith({
    String? id,
    String? brand,
    String? holderName,
    String? last4,
    String? expiry,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      holderName: holderName ?? this.holderName,
      last4: last4 ?? this.last4,
      expiry: expiry ?? this.expiry,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'holderName': holderName,
      'last4': last4,
      'expiry': expiry,
    };
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      brand: json['brand'] as String,
      holderName: json['holderName'] as String,
      last4: json['last4'] as String,
      expiry: json['expiry'] as String,
    );
  }
}
