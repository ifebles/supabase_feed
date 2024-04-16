import 'package:flutter/material.dart';
import 'package:supabase_feed/pages/account.dart';
import 'package:supabase_feed/pages/create_activity.dart';
import 'package:supabase_feed/pages/home.dart';
import 'package:supabase_feed/pages/login.dart';
import 'package:supabase_feed/pages/manage_activity/main.dart';
import 'package:supabase_feed/pages/signup.dart';
import 'package:supabase_feed/pages/splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_feed/secrets.dart';

void main() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(MaterialApp(
    routes: {
      '/': (ctx) => const Splash(),
      '/login': (ctx) => const Login(),
      '/signup': (ctx) => const Signup(),
      '/account': (ctx) => const Account(),
      '/home': (ctx) => const Home(),
      '/create': (ctx) => const CreateActivity(),
      '/manage': (ctx) => const ManageActivity(),
    },
  ));
}
