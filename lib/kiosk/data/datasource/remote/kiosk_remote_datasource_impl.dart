import 'package:dgworld_poc/kiosk/data/dto/kiosk_payment_request.dart';
import 'package:dgworld_poc/utils/config.dart';
import 'package:dio/dio.dart';

import 'kiosk_remote_datasource.dart';

class KioskRemoteDataSourceImpl extends KioskRemoteDataSource {

  @override
  Future<void> pay(KioskPaymentRequest request) async {
    final Dio dio = Dio();

    const url = APIConfig.URL + APIConfig.PAY_ROUTE;

    dio.post(url, data: request.toJson());
  }
}