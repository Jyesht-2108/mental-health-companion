import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mental_health_companion/providers/app_state_provider.dart';
import 'package:mental_health_companion/providers/voice_provider.dart';
import 'package:mental_health_companion/providers/brain_visualization_provider.dart';
import 'package:mental_health_companion/providers/companion_provider.dart';
import 'package:mental_health_companion/routes/app_router.dart';
import 'package:mental_health_companion/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (optional)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization skipped: $e');
  }
  
  // Initialize database
  await DatabaseService.instance.init();
  
  runApp(const MentalHealthCompanionApp());
}

class MentalHealthCompanionApp extends StatelessWidget {
  const MentalHealthCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => VoiceProvider()),
        ChangeNotifierProvider(create: (_) => BrainVisualizationProvider()),
        ChangeNotifierProvider(create: (_) => CompanionProvider()),
      ],
      child: MaterialApp.router(
        title: 'Mental Health Companion',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}

