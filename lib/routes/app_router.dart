import 'package:go_router/go_router.dart';
import 'package:mental_health_companion/screens/home_screen.dart';
import 'package:mental_health_companion/screens/daily_questions_screen.dart';
import 'package:mental_health_companion/screens/brain_visualization_screen.dart';
import 'package:mental_health_companion/screens/companion_chat_screen.dart';
import 'package:mental_health_companion/screens/suggestions_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/questions',
        builder: (context, state) => const DailyQuestionsScreen(),
      ),
      GoRoute(
        path: '/brain',
        builder: (context, state) => const BrainVisualizationScreen(),
      ),
      GoRoute(
        path: '/companion',
        builder: (context, state) => const CompanionChatScreen(),
      ),
      GoRoute(
        path: '/suggestions',
        builder: (context, state) => const SuggestionsScreen(),
      ),
    ],
  );
}

