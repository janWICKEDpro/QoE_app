import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qoe_app/data/local/session_manager.dart';
import 'package:qoe_app/routes/routes.dart';
import 'package:qoe_app/services/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    dotenv.load(fileName: ".env"),
    SessionManager().init(),
    LocationService().initialize(),
  ]);

  final router = RouterClass.instance;

  runApp(FeedbackApp(routes: router));
}

class FeedbackApp extends StatelessWidget {
  final RouterClass routes;

  const FeedbackApp({super.key, required this.routes});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Feedback',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: routes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
