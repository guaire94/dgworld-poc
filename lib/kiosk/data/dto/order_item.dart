import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class OrderItem extends Equatable {
  int id;
  String description;
  double price;
  int quantity;

  OrderItem(
      {@required this.id,
        @required this.description,
        @required this.price,
        @required this.quantity});

  String toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["Id"] = id;
    data["Description"] = description;
    data["Price"] = price;
    data["Qty"] = quantity;

    return json.encode(data);
  }

  @override
  List<Object> get props => [
    id,
    description,
    price,
    quantity
  ];
}