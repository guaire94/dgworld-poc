import 'package:dgworld_poc/kiosk/presentation/screen/kiosk_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'kiosk/data/datasource/remote/kiosk_remote_datasource_impl.dart';
import 'kiosk/data/repository/kiosk_repository.dart';
import 'kiosk/data/repository/kiosk_repository_impl.dart';
import 'kiosk/presentation/bloc/kiosk_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DGworldPOC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (_) => initKioskBloc(),
        child: KioskScreen()
      )
    );
  }
}

KioskBloc initKioskBloc() {
  return KioskBloc(
    kioskRepository: getKioskRepository()
  );
}

KioskRepository getKioskRepository() {
  return KioskRepositoryImpl(
    remoteDataSource: KioskRemoteDataSourceImpl()
  );
}
