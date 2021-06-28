import 'dart:math';

import 'package:dgworld_poc/kiosk/data/dto/kiosk_payment_request.dart';

class APIConfig {
  static const PORT = 56200;
  static const PAY_ROUTE = '/dgworldpos/pay';

  static KioskPaymentRequest createPaymentRequest() {
    final items = _createOrderItems();
    KioskPaymentRequest kioskPaymentRequest = KioskPaymentRequest(
        TalabatOrderId: getRandomString(),
        amount: 100,
        discount: 20,
        finalAmount: 80,
        currency: "AED",
        items: items);

    return kioskPaymentRequest;
  }

  static List<OrderItem> _createOrderItems() {
    return [
      OrderItem(id: 1, description: "Burger", price: 25),
      OrderItem(id: 2, description: "Burger", price: 25),
      OrderItem(id: 3, description: "Burger", price: 25),
      OrderItem(id: 4, description: "Burger", price: 25)
    ];
  }
}

class ServerConfig {
  static const PORT = 19000;
  static const PAYMENT_ROUTE = '/dgworldpos/payment';
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString() => String.fromCharCodes(Iterable.generate(
    16, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
