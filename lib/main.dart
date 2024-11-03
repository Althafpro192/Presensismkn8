import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/splashcreen.dart';
import 'package:flutter/services.dart';
import 'sampah/leave_request_provider.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LeaveRequestProvider()),
        
      ],
      child: MyApp(),
    ),);
     });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}
