import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/screens/landing_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/domain/user_model.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/student/presentation/screens/student_dashboard_screen.dart';
import '../../features/tutor/presentation/screens/tutor_dashboard_screen.dart';
import '../../features/student/presentation/screens/student_profile_edit_screen.dart';
import '../../features/tutor/presentation/screens/tutor_profile_edit_screen.dart';
import '../../features/student/presentation/screens/tutor_search_screen.dart';
import '../../features/student/presentation/screens/tutor_detail_screen.dart';
import '../../features/student/presentation/screens/student_bookings_screen.dart';
import '../../features/tutor/presentation/screens/tutor_bookings_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isProtected = state.matchedLocation.startsWith('/student') || state.matchedLocation.startsWith('/tutor');
      // After sign-up/sign-in we go to /student or /tutor; auth stream may not have updated yet. Don't redirect away while loading.
      if (authState.isLoading && isProtected) return null;
      final isLoggedIn = authState.valueOrNull != null;
      final isLanding = state.matchedLocation == '/';
      final isAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      if (!isLoggedIn && !isLanding && !isAuth) return '/';
      if (isLoggedIn && (isLanding || isAuth)) {
        final role = authState.valueOrNull?.role;
        if (role != null) return role.isStudent ? '/student' : '/tutor';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const LandingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, s) => RegisterScreen(initialRole: s.uri.queryParameters['role'])),
      GoRoute(
        path: '/student',
        builder: (_, __) => const StudentDashboardScreen(),
        routes: [
          GoRoute(path: 'profile/edit', builder: (_, __) => const StudentProfileEditScreen()),
          GoRoute(path: 'search', builder: (_, __) => const TutorSearchScreen()),
          GoRoute(path: 'tutor/:id', builder: (c, s) => TutorDetailScreen(tutorId: s.pathParameters['id']!)),
          GoRoute(path: 'bookings', builder: (_, __) => const StudentBookingsScreen()),
          GoRoute(path: 'chats', builder: (_, __) => const ChatListScreen()),
          GoRoute(path: 'chat/:chatId', builder: (c, s) => ChatScreen(chatId: s.pathParameters['chatId']!)),
        ],
      ),
      GoRoute(
        path: '/tutor',
        builder: (_, __) => const TutorDashboardScreen(),
        routes: [
          GoRoute(path: 'profile/edit', builder: (_, __) => const TutorProfileEditScreen()),
          GoRoute(path: 'bookings', builder: (_, __) => const TutorBookingsScreen()),
          GoRoute(path: 'chats', builder: (_, __) => const ChatListScreen()),
          GoRoute(path: 'chat/:chatId', builder: (c, s) => ChatScreen(chatId: s.pathParameters['chatId']!)),
        ],
      ),
    ],
  );
});
