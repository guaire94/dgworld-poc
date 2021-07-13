import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'order_item.dart';

class KioskPrintRequest extends Equatable {
  String TalabatOrderId;
  double amount;
  double discount;
  double finalAmount;
  String currency;
  List<OrderItem> items;

  @override
  List<Object> get props => [
    TalabatOrderId,
    amount,
    discount,
    finalAmount,
    currency,
    items
  ];

  KioskPrintRequest(
      { @required this.TalabatOrderId,
        @required this.amount,
        @required this.discount,
        @required this.finalAmount,
        @required this.currency,
        @required this.items});

  String toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["TalabatOrderId"] = TalabatOrderId;
    data["Amount"] = amount;
    data["Discount"] = discount;
    data["FinalAmount"] = finalAmount;
    data["Currency"] = currency;
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