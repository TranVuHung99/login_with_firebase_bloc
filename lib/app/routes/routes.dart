import 'package:flutter/widgets.dart';
import 'package:login_with_firebase_bloc/home/home.dart';
import 'package:login_with_firebase_bloc/login/login.dart';
import 'package:login_with_firebase_bloc/models/models.dart';

List<Page> onGenerateAppViewPages(AppStatus state, List<Page<dynamic>> pages) {
  switch (state) {
    case AppStatus.authenticated:
      return [HomePage.page()];
    case AppStatus.unauthenticated:
    default:
      return [LoginPage.page()];
  }
}
