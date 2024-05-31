import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:roomi/src/providers/groups_provider.dart';
import 'src/app.dart';
import 'src/providers/settings_provider.dart';
import 'src/services/settings_service.dart';
import 'src/providers/account_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final settingsController = SettingsProvider(SettingsService());
  await settingsController.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => GroupsProvider()),
      ],
      child: MyApp(settingsController: settingsController),
    ),
  );
}
