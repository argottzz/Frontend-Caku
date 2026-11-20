import 'package:flutter/material.dart';

import 'app.dart';
import 'state/app_scope.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CakuApp(services: AppServices.create()));
}
