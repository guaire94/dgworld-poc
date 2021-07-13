import 'dart:math';

import 'package:dgworld_poc/kiosk/data/dto/kiosk_payment_request.dart';
import 'package:dgworld_poc/kiosk/data/dto/kiosk_print_invoice_request.dart';
import 'package:dgworld_poc/kiosk/data/dto/order_item.dart';

class APIConfig {
  // DGWorld Endpoint
  static const PAY_ROUTE = '/dgworldpos/pay';
  static const PRINT_ROUTE = '/dgworldpos/print';
  static const CHECK_ROUTE = '/dgworldpos/check';

  // TalabatPay Endpoint
  static const VALIDATE_ROUTE = '/api/v1/payments/validate';


  static KioskPaymentRequest createPaymentRequest() {
    final items = _createOrderItems();
    KioskPaymentRequest kioskPaymentRequest = KioskPaymentRequest(
        TalabatOrderId: getRandomString(),
        amount: 100,
        discount: 20,
        finalAmount: 80,
        items: items);

    return kioskPaymentRequest;
  }

  static KioskPrintRequest createPrintRequest(
    String TalabatOrderId,
    String posOrderId,
    String referenceNumber,
    String paymentStatus,
    String dgworldTransactionId,
    String paymentReceipt,
  ) {
    final items = _createOrderItems();
    KioskPrintRequest kioskPrintRequest = KioskPrintRequest(
        TalabatOrderId: TalabatOrderId,
        posOrderId: posOrderId,
        referenceNumber: referenceNumber,
        paymentStatus: paymentStatus,
        dgworldTransactionId: dgworldTransactionId,
        paymentReceipt: paymentReceipt,
        amount: 100,
        discount: 20,
        finalAmount: 80,
        items: items);

    return kioskPrintRequest;
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
  static const PAYMENT_ROUTE = '/dgworldpos/payment';
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString() => String.fromCharCodes(Iterable.generate(
    16, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
