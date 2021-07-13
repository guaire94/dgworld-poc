import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dgworld_poc/kiosk/data/dto/kiosk_validate_request.dart';
import 'package:dgworld_poc/kiosk/data/repository/kiosk_repository.dart';
import 'package:dgworld_poc/utils/config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

class KioskBloc extends Bloc<KioskEvent, KioskState> {
  var myUrl = "";
  var posUrl = "";

  Timer _timer;

  KioskBloc({
    this.kioskRepository,
  }) : super(InitialState());
  final KioskRepository kioskRepository;

  @override
  Stream<KioskState> mapEventToState(
    KioskEvent event,
  ) async* {
    if (event is KioskPayEvent) {
      myUrl = await _getMyUrl();
      posUrl = await _getPosUrl();
      final ableToPay = await kioskRepository.pay(posUrl, APIConfig.createPaymentRequest());
      if (ableToPay) {
        _waitForPaymentResponse();
      } else {
        yield SyncErrorState();
        _waitForCheckSuccess();
      }
    } else if (event is KioskWaitForPaymentEvent) {
        yield WaitingForPaymentState(serverUrl: myUrl);
    } else if (event is KioskPaymentSuccessEvent) {
      yield PaymentSuccessState(
          posOrderId: event.posOrderId,
          transactionId: event.transactionId,
          talabatOrderId: event.talabatOrderId,
          referenceNumber: event.referenceNumber,
          paymentReceipt: event.paymentReceipt,
          paymentStatus: event.paymentStatus);
      _validateOrder(event); // TODO: verify everything's good before printing
      yield await _printReceipt(event);
    } else if (event is KioskPaymentDeclineEvent) {
      yield PaymentDeclineState(
          paymentStatus: event.paymentStatus, errorMessage: event.errorMessage);
    } else if (event is KioskPaymentRejectedEvent) {
      yield PaymentRejectedState(paymentStatus: event.paymentStatus);
    } else if (event is SyncErrorEvent) {
      yield SyncErrorState();
    }
  }

  void _waitForCheckSuccess() {
    _timer =
        new Timer.periodic(const Duration(seconds: 5), (Timer timer) async {
      final ableToPay = await kioskRepository.check(posUrl);
      if (ableToPay) {
        _timer.cancel();
        add(KioskPayEvent());
      }
    });
  }

  void _waitForPaymentResponse() async {
    var app = Router();

    app.post(ServerConfig.PAYMENT_ROUTE, (Request request) async {
      final payload = await request.readAsString();
      final json = jsonDecode(payload);
      final paymentStatus = json["PaymentStatus"];

      if (paymentStatus == "Success") {
        final posOrderId = json["POSOrderId"];
        final transactionId = json["TransactionId"];
        final talabatOrderId = json["TalabatOrderId"];
        final referenceNumber = json["ReferenceNumber"];
        final paymentReceipt = json["PaymentReceipt"];
        final event = KioskPaymentSuccessEvent(
            posOrderId: posOrderId,
            transactionId: transactionId,
            talabatOrderId: talabatOrderId,
            referenceNumber: referenceNumber,
            paymentReceipt: paymentReceipt,
            paymentStatus: paymentStatus);
        add(event);
      } else if (paymentStatus == "Decline") {
        final errorMessage = json["ErrorMessage"];
        add(KioskPaymentDeclineEvent(
            paymentStatus: paymentStatus, errorMessage: errorMessage));
      } else if (paymentStatus == "Rejected") {
        add(KioskPaymentRejectedEvent(paymentStatus: paymentStatus));
      } else if (paymentStatus == "Error") {
        add(SyncErrorEvent(paymentStatus: paymentStatus));
      }
      return Response.ok(payload);
    });

    final myPort = await _getMyPort();
    final myIp = await _getMyIp();
    var server = await shelf_io.serve(app, myIp, int.parse(myPort));
    add(KioskWaitForPaymentEvent(serverUrl: server.address.host));
  }

  void _validateOrder(KioskPaymentSuccessEvent event) async {
    final amount = APIConfig.createPaymentRequest().amount;
    final talabatOrderId = int.parse(event.talabatOrderId);

    final request = KioskValidateRequest(
      receiptUrl: event.paymentReceipt,
      orderId: talabatOrderId,
      transactionId: 123456, // TODO: need to be the transactionId from place order API
      referenceNumber: event.referenceNumber,
      paymentValidationResponse: "",
      amount: amount,
      paymentStatus: 0,
    );
    await kioskRepository.validate(request);
  }

  Future<KioskState> _printReceipt(KioskPaymentSuccessEvent event) async {
    final request = APIConfig.createPrintRequest(
        event.talabatOrderId,
        event.posOrderId,
        event.referenceNumber,
        event.paymentStatus,
        event.transactionId,
        event.paymentReceipt,
    );
    final ableToPrint = await kioskRepository.printReceipt(posUrl, request);
    if (ableToPrint) {
      return PrintSuccessState();
    } else {
      _waitForCheckSuccess();
      return SyncErrorState();
    }
}


  // Helpers
  Future<String> _getMyIp() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type.name == "IPv4") {
          print("You should use this IP as tabIp in ip_config.json and also as TalabatServer in postman env");
          print(addr.address);
          return addr.address;
        }
      }
    }
  }

  Future<String> _getMyPort() async {
    var localIp = await _getMyIp();
    var tabPort = "";
    var jsonText = await rootBundle.loadString('assets/ip_config.json');
    var data = json.decode(jsonText);
    var ips = data as List;
    for (var element in ips) {
      if (element["tabIp"] == localIp) {
        tabPort = element["tabPort"];
        break;
      }
    }
    return tabPort;
  }

  Future<String> _getMyUrl() async {
    var localIp = await _getMyIp();
    var tabIp = "";
    var tabPort = await _getMyPort();
    var jsonText = await rootBundle.loadString('assets/ip_config.json');
    var data = json.decode(jsonText);
    var ips = data as List;
    for (var element in ips) {
      if (element["tabIp"] == localIp) {
        tabIp = element["tabIp"];
        break;
      }
    }
    return "http://${tabIp}:${tabPort}";
  }

  Future<String> _getPosUrl() async {
    var localIp = await _getMyIp();
    var posIp = "";
    var posPort = "";
    var jsonText = await rootBundle.loadString('assets/ip_config.json');
    var data = json.decode(jsonText);
    var ips = data as List;
    for (var element in ips) {
      if (element["tabIp"] == localIp) {
        posIp = element["posIp"];
        posPort = element["posPort"];
        break;
      }
    }
    return "http://${posIp}:${posPort}";
  }
}

// Event
abstract class KioskEvent extends Equatable {
  const KioskEvent();
}

class KioskPayEvent extends KioskEvent {
  @override
  List<Object> get props => [];
}

class KioskWaitForPaymentEvent extends KioskEvent {
  KioskWaitForPaymentEvent({this.serverUrl});

  final String serverUrl;

  @override
  List<Object> get props => [serverUrl];
}

class KioskPaymentSuccessEvent extends KioskEvent {
  KioskPaymentSuccessEvent(
      {this.posOrderId,
      this.transactionId,
      this.talabatOrderId,
      this.referenceNumber,
      this.paymentStatus,
      this.paymentReceipt});

  final String posOrderId;
  final String transactionId;
  final String talabatOrderId;
  final String referenceNumber;
  final String paymentStatus;
  final String paymentReceipt;

  @override
  List<Object> get props => [
        posOrderId,
        transactionId,
        talabatOrderId,
        referenceNumber,
        paymentStatus,
        paymentReceipt
      ];
}

class KioskPaymentDeclineEvent extends KioskEvent {
  KioskPaymentDeclineEvent({this.paymentStatus, this.errorMessage});

  final String paymentStatus;
  final String errorMessage;

  @override
  List<Object> get props => [paymentStatus, errorMessage];
}

class KioskPaymentRejectedEvent extends KioskEvent {
  @override
  KioskPaymentRejectedEvent({this.paymentStatus});

  final String paymentStatus;

  @override
  List<Object> get props => [paymentStatus];
}

class SyncErrorEvent extends KioskEvent {
  @override
  SyncErrorEvent({this.paymentStatus});

  final String paymentStatus;

  @override
  List<Object> get props => [paymentStatus];
}

// State
abstract class KioskState extends Equatable {
  const KioskState();

  @override
  List<Object> get props => [];
}

class InitialState extends KioskState {}

class WaitingForPaymentState extends KioskState {
  WaitingForPaymentState({this.serverUrl});

  final String serverUrl;

  @override
  List<Object> get props => [serverUrl];
}

class PaymentSuccessState extends KioskState {
  PaymentSuccessState(
      {this.posOrderId,
      this.transactionId,
      this.talabatOrderId,
      this.referenceNumber,
      this.paymentStatus,
      this.paymentReceipt});

  final String posOrderId;
  final String transactionId;
  final String talabatOrderId;
  final String referenceNumber;
  final String paymentStatus;
  final String paymentReceipt;

  @override
  List<Object> get props => [
        posOrderId,
        transactionId,
        talabatOrderId,
        referenceNumber,
        paymentStatus,
        paymentReceipt
      ];
}

class PrintSuccessState extends KioskState {}

class PaymentDeclineState extends KioskState {
  PaymentDeclineState({this.paymentStatus, this.errorMessage});

  final String paymentStatus;
  final String errorMessage;

  @override
  List<Object> get props => [paymentStatus, errorMessage];
}

class PaymentRejectedState extends KioskState {
  @override
  PaymentRejectedState({this.paymentStatus});

  final String paymentStatus;

  @override
  List<Object> get props => [paymentStatus];
}

class SyncErrorState extends KioskState {}

class NoInternetErrorState extends KioskState {}
