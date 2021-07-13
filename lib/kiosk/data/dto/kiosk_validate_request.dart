import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class KioskValidateRequest extends Equatable {
  String receiptUrl;
  int orderId;
  int transactionId;
  String referenceNumber;
  String paymentValidationResponse;
  double amount;
  int paymentStatus;

  @override
  List<Object> get props => [
    receiptUrl,
    orderId,
    transactionId,
    referenceNumber,
    paymentValidationResponse,
    amount,
    paymentStatus
  ];

  KioskValidateRequest(
      { @required this.receiptUrl,
        @required this.orderId,
        @required this.transactionId,
        @required this.referenceNumber,
        @required this.paymentValidationResponse,
        @required this.amount,
        @required this.paymentStatus,
      });

  String toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["paymentReceiptUrl"] = receiptUrl;
    data["orderId"] = orderId;
    data["transactionId"] = transactionId;
    data["paymentReferenceId"] = referenceNumber;
    data["paymentValidationResponse"] = paymentValidationResponse;
    data["paymentStatus"] = paymentStatus;
    data["amount"] = amount;
    return json.encode(data);
  }
}