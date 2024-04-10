import 'package:flutter/material.dart';
import 'package:supabase_feed/pages/create.dart';
import 'package:supabase_feed/pages/home.dart';
import 'package:supabase_feed/pages/update.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_feed/secrets.dart';

void main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(MaterialApp(
    routes: {
      '/': (ctx) => const Home(),
      '/create': (ctx) => const Create(),
      '/update': (ctx) => const Update(),
    },
  ));
}
