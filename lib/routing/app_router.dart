import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/wallet/wallet_screen.dart';
import '../features/pay/pay_screen.dart';
import '../features/receive/receive_screen.dart';
import '../features/nearby/nearby_screen.dart';
import '../features/mesh/mesh_screen.dart';
import '../features/transactions/transactions_screen.dart';
import '../features/transactions/transaction_details_screen.dart';
import '../features/gateway/gateway_screen.dart';
import '../features/security/security_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/demo/demo_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/dashboard', builder: (c, s) => const DashboardScreen()),
      GoRoute(path: '/wallet', builder: (c, s) => const WalletScreen()),
      GoRoute(path: '/pay', builder: (c, s) => const PayScreen()),
      GoRoute(path: '/receive', builder: (c, s) => const ReceiveScreen()),
      GoRoute(path: '/nearby', builder: (c, s) => const NearbyScreen()),
      GoRoute(path: '/mesh', builder: (c, s) => const MeshScreen()),
      GoRoute(path: '/transactions', builder: (c, s) => const TransactionsScreen()),
      GoRoute(path: '/transactions/:id', builder: (c, s) => const TransactionDetailsScreen()),
      GoRoute(path: '/gateway', builder: (c, s) => const GatewayScreen()),
      GoRoute(path: '/security', builder: (c, s) => const SecurityScreen()),
      GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
      GoRoute(path: '/demo', builder: (c, s) => const DemoScreen()),
    ],
  );
}
