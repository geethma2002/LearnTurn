import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If Firebase fails to initialize (missing config or unsupported platform),
    // continue running the app with mock/local data so UI can be shown.
    // The app's services handle falling back to mock data when Firestore calls fail.
    // Print the error for debugging.
    // ignore: avoid_print
    print('Warning: Firebase.initializeApp failed: $e');
  }
  runApp(const LearnTurnApp());
}

class LearnTurnApp extends StatelessWidget {
  const LearnTurnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnTurn',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

