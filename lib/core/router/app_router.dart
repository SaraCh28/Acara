import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/onboarding/presentation/interest_selection_screen.dart';
import '../../features/onboarding/presentation/location_permission_screen.dart';
import '../../features/onboarding/presentation/city_selection_screen.dart';
import '../../features/main/presentation/main_screen.dart';
import '../../features/event_detail/presentation/event_detail_screen.dart';
import '../../features/profile/presentation/my_bookings_screen.dart';
import '../../features/profile/presentation/payment_methods_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/checkout/presentation/ticket_selection_screen.dart';
import '../../features/checkout/presentation/payment_screen.dart';
import '../../features/checkout/presentation/booking_confirmation_screen.dart';
import '../../features/checkout/presentation/contact_info_screen.dart';
import '../../features/checkout/presentation/view_ticket_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/shared/presentation/notifications_screen.dart';
import '../../features/shared/presentation/category_events_screen.dart';
import '../../features/shared/presentation/ai_assistant_screen.dart';
import '../../models/event_model.dart';
import '../../services/auth_service.dart';

import '../../features/onboarding/presentation/name_avatar_selection_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final user = ref.read(currentUserProvider);
      final isAuthRoute = [
        '/login',
        '/signup',
        '/onboarding',
        '/splash',
        '/forgot_password',
        '/reset_password',
      ].contains(state.matchedLocation);

      if (user == null && !isAuthRoute) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => Theme(data: AppTheme.lightTheme, child: const SplashScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => Theme(data: AppTheme.lightTheme, child: const OnboardingScreen()),
      ),
      GoRoute(path: '/login', builder: (context, state) => Theme(data: AppTheme.lightTheme, child: const LoginScreen())),
      GoRoute(
        path: '/signup',
        builder: (context, state) => Theme(data: AppTheme.lightTheme, child: const SignupScreen()),
      ),
      GoRoute(
        path: '/forgot_password',
        builder: (context, state) =>
            Theme(data: AppTheme.lightTheme, child: ForgotPasswordScreen(authService: ref.read(authServiceProvider))),
      ),
      GoRoute(
        path: '/reset_password',
        builder: (context, state) => Theme(data: AppTheme.lightTheme, child: const ResetPasswordScreen()),
      ),
      GoRoute(
        path: '/name_selection',
        builder: (context, state) => Theme(data: AppTheme.lightTheme, child: const NameAvatarSelectionScreen()),
      ),
      GoRoute(
        path: '/interests',
        builder: (context, state) => Theme(data: AppTheme.lightTheme, child: const InterestSelectionScreen()),
      ),
      GoRoute(
        path: '/location_permission',
        builder: (context, state) => Theme(data: AppTheme.lightTheme, child: const LocationPermissionScreen()),
      ),
      GoRoute(
        path: '/city_selection',
        builder: (context, state) => Theme(data: AppTheme.lightTheme, child: const CitySelectionScreen()),
      ),
      GoRoute(path: '/home', builder: (context, state) => const MainScreen()),
      GoRoute(
        path: '/search',
        builder: (context, state) => const ExploreScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/ai_assistant',
        builder: (context, state) => const AiAssistantScreen(),
      ),
      GoRoute(
        path: '/category/:name',
        builder: (context, state) {
          final name = Uri.decodeComponent(state.pathParameters['name']!);
          return CategoryEventsScreen(category: name);
        },
      ),
      GoRoute(
        name: 'event_detail',
        path: '/event/:id',
        builder: (context, state) {
          final id = Uri.decodeComponent(state.pathParameters['id']!);
          return EventDetailScreen(eventId: id);
        },
      ),
      GoRoute(
        name: 'booking',
        path: '/booking/:id',
        builder: (context, state) {
          final id = Uri.decodeComponent(state.pathParameters['id']!);
          final initialEvent = state.extra is EventModel ? state.extra as EventModel : null;
          return TicketSelectionScreen(
            key: ValueKey('booking-$id'),
            eventId: id,
            initialEvent: initialEvent,
          );
        },
      ),
      GoRoute(
        name: 'contact_info',
        path: '/contact_info/:id',
        builder: (context, state) {
          final id = Uri.decodeComponent(state.pathParameters['id']!);
          final initialEvent = state.extra is EventModel ? state.extra as EventModel : null;
          return ContactInfoScreen(
            key: ValueKey('contact-$id'),
            eventId: id,
            initialEvent: initialEvent,
          );
        },
      ),
      GoRoute(
        name: 'payment_selection',
        path: '/payment_selection/:id',
        builder: (context, state) {
          final id = Uri.decodeComponent(state.pathParameters['id']!);
          final initialEvent = state.extra is EventModel ? state.extra as EventModel : null;
          return PaymentScreen(
            key: ValueKey('payment-$id'),
            eventId: id,
            initialEvent: initialEvent,
          );
        },
      ),
      GoRoute(
        name: 'booking_confirmation',
        path: '/booking_confirmation/:id',
        builder: (context, state) {
          final id = Uri.decodeComponent(state.pathParameters['id']!);
          final initialEvent = state.extra is EventModel ? state.extra as EventModel : null;
          return BookingConfirmationScreen(
            key: ValueKey('confirmation-$id'),
            bookingId: id,
            initialEvent: initialEvent,
          );
        },
      ),
      GoRoute(
        name: 'view_ticket',
        path: '/view_ticket/:id',
        builder: (context, state) {
          final id = Uri.decodeComponent(state.pathParameters['id']!);
          final initialEvent = state.extra is EventModel ? state.extra as EventModel : null;
          return ViewTicketScreen(
            key: ValueKey('ticket-$id'),
            bookingId: id,
            initialEvent: initialEvent,
          );
        },
      ),
      GoRoute(
        path: '/profile/bookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: '/profile/payments',
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: '/profile/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
