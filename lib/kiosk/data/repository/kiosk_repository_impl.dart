import 'package:dgworld_poc/kiosk/data/datasource/remote/kiosk_remote_datasource.dart';
import 'package:flutter/foundation.dart';
import 'kiosk_repository.dart';

class KioskRepositoryImpl extends KioskRepository {
  KioskRepositoryImpl({
    @required remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final KioskRemoteDataSource _remoteDataSource;

  @override
  Future<void> pay() async {
    try {
      final result = await _remoteDataSource.pay();
      return result;
    } catch (e) {
      rethrow;
    }
  }
}