import 'package:dgworld_poc/kiosk/data/dto/kiosk_payment_request.dart';
import 'package:dgworld_poc/kiosk/data/dto/kiosk_print_invoice_request.dart';
import 'package:dgworld_poc/kiosk/data/dto/kiosk_validate_request.dart';

abstract class KioskRepository {
  // DGWorld Endpoint
  Future<bool> pay(String posUrl, KioskPaymentRequest request);
  Future<bool> printReceipt(String posUrl, KioskPrintRequest request);
  Future<bool> check(String posUrl);

  // TalabatPay Endpoint
  Future<bool> validate(KioskValidateRequest request);
}