import 'package:equatable/equatable.dart';

abstract class TalabatException extends Equatable implements Exception {
  final String message;

  TalabatException(this.message);
}

class NoInternetException extends TalabatException {
  NoInternetException(String message) : super(message);

  @override
  List<Object> get props => [message];
}

class ServerException extends TalabatException {
  ServerException(String message) : super(message);

  @override
  List<Object> get props => [message];
}

class NativeException extends TalabatException {
  NativeException(String message) : super(message);

  @override
  List<Object> get props => [message];
}

class ResponseParsingException extends TalabatException {
  ResponseParsingException(String message) : super(message);

  @override
  List<Object> get props => [message];
}
