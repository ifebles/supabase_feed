import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListEntry extends StatefulWidget {
  final Map<String, dynamic> dict;

  const ListEntry(this.dict, {super.key});

  @override
  State<ListEntry> createState() => _ListEntryState();
}

class _ListEntryState extends State<ListEntry> {
  @override
  Widget build(BuildContext context) {
    var dict = widget.dict;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/update', arguments: {
          'id': dict['id'],
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dict['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text('${dict['detail']}'),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                DateFormat('dd/MM/yyyy hh:mm a')
                    .format(DateTime.parse(dict['date']).toLocal()),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
