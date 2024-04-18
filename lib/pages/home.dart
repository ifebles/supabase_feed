import 'package:flutter/material.dart';
import 'package:supabase_feed/enums/loading_status.dart';
import 'package:supabase_feed/components/list_entry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final client = Supabase.instance.client;
  final _activityStream =
      Supabase.instance.client.from('activity').stream(primaryKey: ['id']);

  var loadingStatus = LoadingStatus.loading;
  List<Map<String, dynamic>> data = [];

  @override
  Widget build(BuildContext context) {
    final body = StreamBuilder(
      stream: _activityStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blueAccent[700],
            ),
          );
        }

        final data = snapshot.data!;

        if (data.isEmpty) {
          return Center(
            child: Text(
              'The list is empty',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }

        return ListView.separated(
          separatorBuilder: (context, index) => const Divider(height: 20),
          itemCount: data.length,
          itemBuilder: (context, index) => ListEntry(data[index]),
        );
      },
    );

    return Scaffold(
      body: SafeArea(child: body),
      floatingActionButton: IconButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create');
        },
        icon: const Icon(Icons.add),
        color: Colors.white,
        iconSize: 40,
        style: IconButton.styleFrom(
          backgroundColor: Colors.blueAccent[700],
        ),
      ),
    );
  }
}
