import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'order_item.dart';

class KioskPrintRequest extends Equatable {
  String posOrderId;
  String TalabatOrderId;
  String referenceNumber;
  String paymentStatus;
  String dgworldTransactionId;
  String paymentReceipt;
  double amount;
  double discount;
  double finalAmount;
  List<OrderItem> items;

  @override
  List<Object> get props => [
    posOrderId,
    TalabatOrderId,
    referenceNumber,
    paymentStatus,
    dgworldTransactionId,
    paymentReceipt,
    amount,
    discount,
    finalAmount,
    items
  ];

  KioskPrintRequest(
      { @required this.posOrderId,
        @required this.TalabatOrderId,
        @required this.referenceNumber,
        @required this.paymentStatus,
        @required this.dgworldTransactionId,
        @required this.paymentReceipt,
        @required this.amount,
        @required this.discount,
        @required this.finalAmount,
        @required this.items});

  String toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["POSOrderId"] = posOrderId;
    data["TalabatOrderId"] = TalabatOrderId;
    data["ReferenceNumber"] = referenceNumber;
    data["PaymentStatus"] = paymentStatus;
    data["TransactionId"] = dgworldTransactionId;
    data["PaymentReceipt"] = paymentReceipt;
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