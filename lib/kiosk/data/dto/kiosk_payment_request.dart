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
  String POSOrderId;
  String TalabatOrderId;
  double amount;
  double discount;
  double finalAmount;
  String currency;
  List<OrderItem> items;

  @override
  List<Object> get props => [
    POSOrderId,
    TalabatOrderId,
    amount,
    discount,
    finalAmount,
    currency,
    items
  ];

  KioskPaymentRequest(
      {@required this.POSOrderId,
        @required this.TalabatOrderId,
        @required this.amount,
        @required this.discount,
        @required this.finalAmount,
        @required this.currency,
        @required this.items});

  String toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["POSOrderId"] = POSOrderId;
    data["TalabatOrderId"] = TalabatOrderId;
    data["Amount"] = amount;
    data["Discount"] = discount;
    data["FinalAmount"] = finalAmount;
    data["Currency"] = currency;
    data["OrderDetails"] = jsonEncode(items);;

    return json.encode(data);
  }
}