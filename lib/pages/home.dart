import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_feed/enums/loading_status.dart';
import 'package:supabase_feed/widgets/list_entry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final client = Supabase.instance.client;
  var loadingStatus = LoadingStatus.loading;
  List<Map<String, dynamic>> data = [];

  void fetchData() async {
    var fail = false;
    var result = await client.from('activity').select().catchError((error) {
      if (kDebugMode) {
        print(error);
      }

      fail = true;

      return <Map<String, dynamic>>[];
    });

    setState(() {
      loadingStatus = fail ? LoadingStatus.fail : LoadingStatus.success;
      data = result;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (loadingStatus == LoadingStatus.loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (loadingStatus == LoadingStatus.fail) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Unable to load the required information',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 5),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  loadingStatus = LoadingStatus.loading;
                  data = [];
                });

                fetchData();
              },
              style: ButtonStyle(
                  foregroundColor:
                      MaterialStatePropertyAll(Colors.blueAccent[700])),
              icon: const Icon(Icons.refresh),
              label: const Text(
                'Retry',
              ),
            )
          ],
        ),
      );
    } else if (data.isEmpty) {
      body = Center(
        child: Text(
          'The list is empty',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[400],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    } else {
      body = ListView.separated(
        separatorBuilder: (context, index) => const Divider(height: 20),
        itemCount: data.length,
        itemBuilder: (context, index) => ListEntry(data[index]),
      );
    }

    return Scaffold(
      body: SafeArea(child: body),
      floatingActionButton: IconButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create');
        },
        icon: const Icon(Icons.add),
        color: Colors.white,
        iconSize: 40,
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Colors.blueAccent[700]),
        ),
      ),
    );
  }
}
