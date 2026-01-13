import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'ui/login_page.dart';
import 'utils/constants.dart';
import 'utils/notification_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // oke jadi ini buat setup format tanggal Indonesia biar rapi
  await initializeDateFormatting('id_ID', null);
  
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await NotificationHelper().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Jadwal Piket Cerdas',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const LoginPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
