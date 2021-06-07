import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dgworld_poc/kiosk/data/repository/kiosk_repository.dart';
import 'package:equatable/equatable.dart';

class KioskBloc extends Bloc<KioskEvent, KioskState> {

  KioskBloc({
    this.kioskRepository,
  })  : super(InitialState());
  final KioskRepository kioskRepository;

  @override
  Stream<KioskState> mapEventToState(
      KioskEvent event,
      ) async* {
    if (event is KioskPayEvent) {
      yield LoadingState();
      kioskRepository.pay();
    } else if (event is KioskPaySuccessEvent) {
      yield LoadedState();
    } else if (event is KioskPayFailEvent) {
      yield ErrorState();
    }
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

class KioskPaySuccessEvent extends KioskEvent {
  @override
  List<Object> get props => [];
}

class KioskPayFailEvent extends KioskEvent {
  @override
  List<Object> get props => [];
}

// State
abstract class KioskState extends Equatable {
  const KioskState();
}

class InitialState extends KioskState {
  @override
  List<Object> get props => [];
}

class LoadingState extends KioskState {
  @override
  List<Object> get props => [];
}

class LoadedState extends KioskState {
  @override
  List<Object> get props => [];
}

class NoInternetErrorState extends KioskState {
  @override
  List<Object> get props => [];
}

class ErrorState extends KioskState {
  @override
  List<Object> get props => [];
}