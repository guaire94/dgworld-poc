import 'package:dgworld_poc/kiosk/data/dto/kiosk_payment_request.dart';
import 'package:dio/dio.dart';

import 'kiosk_remote_datasource.dart';

class KioskRemoteDataSourceImpl extends KioskRemoteDataSource {

  @override
  Future<void> pay() async {
    final Dio dio = Dio();

    const url = 'http://192.168.1.250:56200/dgworldpos/pay'; // http://192.168.1.xx:56200
    final data = createPaymentRequests();

    dio.post(url, data: data.toJson());
  }

  KioskPaymentRequests createPaymentRequests() {
    final items = createOrderItems();
    KioskPaymentRequest kioskPaymentRequest = KioskPaymentRequest(
        orderId: "orderXXXXX",
        referenceNumber: "",
        amount: 100,
        discount: 20,
        finalAmount: 80,
        currency: "AED",
        discountDescription: "-20%",
        paymentStatus: "",
        paymentReceipt: "",
        items: items);

    KioskPaymentRequests kioskPaymentRequests = KioskPaymentRequests(requests: [kioskPaymentRequest]);
    return kioskPaymentRequests;
  }

  List<OrderItem> createOrderItems() {
    return [
      OrderItem(id: 1, description: "Burger", price: 25),
      OrderItem(id: 2, description: "Burger", price: 25),
      OrderItem(id: 3, description: "Burger", price: 25),
      OrderItem(id: 4, description: "Burger", price: 25)
    ];
  }
}
