import 'package:flutter/material.dart';
import 'package:supabase_feed/pages/create.dart';
import 'package:supabase_feed/pages/home.dart';
import 'package:supabase_feed/pages/update.dart';

void main() async {
  runApp(MaterialApp(
    routes: {
      '/': (ctx) => const Home(),
      '/create': (ctx) => const Create(),
      '/update': (ctx) => const Update(),
    },
  ));
}
