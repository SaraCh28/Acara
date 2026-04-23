import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/payment_method_model.dart';

final paymentMethodsProvider =
    NotifierProvider<PaymentMethodsNotifier, List<PaymentMethodModel>>(
      PaymentMethodsNotifier.new,
    );

class PaymentMethodsNotifier extends Notifier<List<PaymentMethodModel>> {
  static const _storageKey = 'payment_methods';
  final _uuid = const Uuid();

  @override
  List<PaymentMethodModel> build() {
    return const [
      PaymentMethodModel(
        id: 'card_visa_4242',
        brand: 'Visa',
        holderName: 'Sarah Ahmed',
        last4: '4242',
        expiry: '12/27',
      ),
      PaymentMethodModel(
        id: 'card_master_8812',
        brand: 'Mastercard',
        holderName: 'Sarah Ahmed',
        last4: '8812',
        expiry: '04/28',
      ),
    ];
  }

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      await _persist();
      return;
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    state = decoded
        .map(
          (item) => PaymentMethodModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> addCard({
    required String brand,
    required String holderName,
    required String cardNumber,
    required String expiry,
  }) async {
    final digitsOnly = cardNumber.replaceAll(RegExp(r'\s+'), '');
    state = [
      ...state,
      PaymentMethodModel(
        id: _uuid.v4(),
        brand: brand,
        holderName: holderName,
        last4: digitsOnly.substring(digitsOnly.length - 4),
        expiry: expiry,
      ),
    ];
    await _persist();
  }

  Future<void> removeCard(String id) async {
    state = state.where((card) => card.id != id).toList();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(state.map((card) => card.toJson()).toList()),
    );
  }
}
