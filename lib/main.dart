import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/bottom_sheets.service.dart';
import 'package:manager/services/dialogs.service.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/services/notification.service.dart';

import 'app/app.view.dart';
import 'core/locator.dart';
import 'core/storage/prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp();

  await initPrefs();
  await setupStorage();
  AppLogger.info(getUser().toJson());

  setUpLocators();
  setUpBottomSheets();
  setUpDialogs();
  await LanguageService.load();

  NotificationService notificationService = NotificationService();
  await notificationService.init();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryLight,
              AppColors.primaryDark,
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            stops: [0.08, 1],
          ),
        ),
        child: Scaffold(
          body: const AppView(),
          backgroundColor: AppColors.transparent,
        ),
      ),
    ),
  );
}