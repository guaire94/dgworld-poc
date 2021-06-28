import 'package:dgworld_poc/kiosk/data/dto/kiosk_payment_request.dart';

abstract class KioskRepository {
  Future<bool> pay(String posIp, KioskPaymentRequest request);
  Future<bool> check(String posIp);
}