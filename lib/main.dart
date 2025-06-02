import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'services/supabase_service.dart';
import 'core/constants/app_constants.dart';
import 'features/products/product_list_screen.dart';
import 'features/products/product_bloc.dart';
import 'features/products/product_repository.dart';
import 'features/admin/admin_login_screen.dart';
import 'features/admin/admin_auth_bloc.dart';
import 'features/admin/admin_auth_repository.dart';
import 'features/admin/admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService().init();
  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: AppConstants.homeRoute,
      builder: (context, state) => const ProductListScreen(),
    ),
    GoRoute(
      path: AppConstants.adminRoute,
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
      redirect: (context, state) {
        final authBloc = BlocProvider.of<AdminAuthBloc>(context, listen: false);
        final isAuthenticated = authBloc.repository.currentUser != null;
        if (!isAuthenticated) {
          return AppConstants.adminRoute;
        }
        return null;
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProductBloc(ProductRepository())),
        BlocProvider(create: (_) => AdminAuthBloc(AdminAuthRepository())),
      ],
      child: MaterialApp.router(
        title: 'UK International Perfumes',
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
