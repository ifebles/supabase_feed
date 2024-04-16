import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_feed/enums/loading_status.dart';
import 'package:supabase_feed/components/datetime_form_field.dart';
import 'package:supabase_feed/components/sized_progress_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateActivity extends StatefulWidget {
  const CreateActivity({super.key});

  @override
  State<CreateActivity> createState() => _CreateActivityState();
}

class _CreateActivityState extends State<CreateActivity> {
  final client = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _datetimeController = TextEditingController();
  final fields = <String, dynamic>{};
  LoadingStatus? loadingStatus;

  @override
  void dispose() {
    _datetimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Activity'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                onSaved: (newValue) => fields['title'] = newValue,
                decoration: const InputDecoration(
                  label: Text('Activity title'),
                  labelStyle: TextStyle(fontSize: 18),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid title';
                  }

                  return null;
                },
              ),
              TextFormField(
                onSaved: (newValue) => fields['detail'] = newValue,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(
                  label: Text('Activity details'),
                  labelStyle: TextStyle(fontSize: 18),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some details for the activity';
                  }

                  return null;
                },
              ),
              DatetimeFormField(
                onSaved: (newDate) =>
                    fields['date'] = newDate!.toIso8601String(),
                controller: _datetimeController,
                firstDate: DateTime.now(),
                decoration: const InputDecoration(
                  label: Text('Activity date & time'),
                  labelStyle: TextStyle(fontSize: 18),
                  prefixIcon: Icon(Icons.calendar_month),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please enter a valid date & time';
                  }

                  return null;
                },
              ),
              const Expanded(child: SizedBox()),
              ElevatedButton.icon(
                icon: loadingStatus == LoadingStatus.loading
                    ? const SizedProgressIndicator(
                        diameter: 25,
                        strokeWidth: 3,
                        color: Colors.white,
                      )
                    : const Icon(Icons.add),
                label: const Text('Create'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18, letterSpacing: 1),
                ),
                onPressed: () {
                  if (loadingStatus != null ||
                      _formKey.currentState?.validate() != true) {
                    return;
                  }

                  _formKey.currentState?.save();
                  var fail = false;

                  setState(() {
                    loadingStatus = LoadingStatus.loading;
                  });

                  client.from('activity').insert(fields).catchError((error) {
                    fail = true;

                    if (kDebugMode) {
                      print(error);
                    }
                  }).then((value) {
                    var message = 'Activity succesfully created';
                    LoadingStatus? newStatus = LoadingStatus.success;

                    if (fail) {
                      message = 'A problem ocurred creating the activity';
                      newStatus = null;
                    }

                    setState(() {
                      loadingStatus = newStatus;
                    });

                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(
                          content: Text(message),
                        ))
                        .closed
                        .then((value) {
                      if (loadingStatus == LoadingStatus.success) {
                        Navigator.pop(context);
                      }
                    });
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
