import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'order_item.dart';

class KioskPaymentRequest extends Equatable {
  String TalabatOrderId;
  double amount;
  double discount;
  double finalAmount;
  List<OrderItem> items;

  @override
  List<Object> get props => [
    TalabatOrderId,
    amount,
    discount,
    finalAmount,
    items
  ];

  KioskPaymentRequest(
      { @required this.TalabatOrderId,
        @required this.amount,
        @required this.discount,
        @required this.finalAmount,
        @required this.items});

  String toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["TalabatOrderId"] = TalabatOrderId;
    data["Amount"] = amount;
    data["Discount"] = discount;
    data["FinalAmount"] = finalAmount;
    data["OrderDetails"] = jsonEncode(items);

    // QRCode needed
    data["OID"] = TalabatOrderId;
    List<List<int>> qrCodeFormat = [];
    for (final item in items) {
      qrCodeFormat.add([item.quantity, item.id]);
    }
    data["O"] = jsonEncode(qrCodeFormat);

    return json.encode(data);
  }
}