import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
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
      final ableToPay = await kioskRepository.pay(myUrl, APIConfig.createPaymentRequest());
      if (ableToPay) {
        _waitForPaymentResponse();
      } else {
        yield SyncErrorState();
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
    } else if (event is KioskPaymentDeclineEvent) {
      yield PaymentDeclineState(
          paymentStatus: event.paymentStatus, errorMessage: event.errorMessage);
    } else if (event is KioskPaymentRejectedEvent) {
      yield PaymentRejectedState(paymentStatus: event.paymentStatus);
    } else if (event is SyncErrorEvent) {
      yield SyncErrorState();
    }
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

    var server = await shelf_io.serve(app, myUrl, ServerConfig.PORT);
    add(KioskWaitForPaymentEvent(serverUrl: server.address.host));
  }

  Future<String> _getMyIp() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type.name == "IPv4") {
          return addr.address;
        }
      }
    }
  }

  Future<String> _getMyUrl() async {
    var localIp = await _getMyIp();
    var tabIp = "";
    var tabPort = "";
    var jsonText = await rootBundle.loadString('assets/ip_config.json');
    print(jsonText);
    var data = json.decode(jsonText);
    var ips = data as List;
    print(ips);
    for (var element in ips) {
      print("tabIp : ${element["tabIp"]}");
      print("posIp : ${element["posIp"]}");
      if (element["tabIp"] == localIp) {
        tabIp = element["tabIp"];
        tabPort = element["tabPort"];
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
    print(jsonText);
    var data = json.decode(jsonText);
    var ips = data as List;
    print(ips);
    for (var element in ips) {
      print("tabIp : ${element["tabIp"]}");
      print("posIp : ${element["posIp"]}");
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
