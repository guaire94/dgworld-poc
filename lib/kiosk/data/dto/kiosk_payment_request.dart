import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class OrderItem extends Equatable {
  int id;
  String description;
  double price;

  OrderItem(
      {@required this.id,
        @required this.description,
        @required this.price});

  String toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["Id"] = id;
    data["Description"] = description;
    data["Price"] = price;

    return json.encode(data);
  }

  @override
  List<Object> get props => [
    id,
    description,
    price
  ];
}

class KioskPaymentRequest extends Equatable {
  String orderId;
  String referenceNumber;
  double amount;
  double discount;
  double finalAmount;
  String currency;
  String discountDescription;
  String paymentStatus;
  String paymentReceipt;
  List<OrderItem> items;

  @override
  List<Object> get props => [
    orderId,
    referenceNumber,
    amount,
    discount,
    finalAmount,
    currency,
    discountDescription,
    paymentStatus,
    paymentReceipt,
    items
  ];

  KioskPaymentRequest(
      {@required this.orderId,
        @required this.referenceNumber,
        @required this.amount,
        @required this.discount,
        @required this.finalAmount,
        @required this.currency,
        @required this.discountDescription,
        @required this.paymentStatus,
        @required this.paymentReceipt,
        @required this.items});

  String toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["OrderId"] = orderId;
    data["ReferenceNumber"] = referenceNumber;
    data["Amount"] = amount;
    data["Discount"] = discount;
    data["FinalAmount"] = finalAmount;
    data["Currency"] = currency;
    data["DiscountDescription"] = discountDescription;
    data["PaymentStatus"] = paymentStatus;
    data["PaymentReceipt"] = paymentReceipt;
    data["OrderDetails"] = jsonEncode(items);;

    return json.encode(data);
  }
}