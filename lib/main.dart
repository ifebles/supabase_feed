import 'package:flutter/material.dart';
import 'package:supabase_feed/pages/create_activity.dart';
import 'package:supabase_feed/pages/home.dart';
import 'package:supabase_feed/pages/manage_activity/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_feed/secrets.dart';

void main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(MaterialApp(
    routes: {
      '/': (ctx) => const Home(),
      '/create': (ctx) => const CreateActivity(),
      '/manage': (ctx) => const ManageActivity(),
    },
  ));
}
