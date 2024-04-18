import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_feed/components/image_selector.dart';
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
  MapEntry<String?, Uint8List>? image;

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
              const SizedBox(height: 15),
              ImageSelector(
                selectLabel: 'Select a poster for the activity',
                onImageChanged: (name, imageBytes) {
                  if (imageBytes == null) {
                    image = null;
                  } else {
                    image = MapEntry(name, imageBytes);
                  }
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
                  backgroundColor: Colors.blueAccent[700],
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18, letterSpacing: 1),
                ),
                onPressed: () async {
                  if (loadingStatus != null ||
                      _formKey.currentState?.validate() != true) {
                    return;
                  }

                  _formKey.currentState?.save();
                  var status = 0;

                  setState(() {
                    loadingStatus = LoadingStatus.loading;
                  });

                  final inserted = await client
                      .from('activity')
                      .insert(fields)
                      .select('id')
                      .single()
                      .catchError((error) {
                    status = 1;

                    if (kDebugMode) {
                      print(error);
                    }

                    return <String, dynamic>{};
                  });

                  if (status == 0 && image != null && image!.key != null) {
                    final ext = image!.key!.split('.').last.toLowerCase();

                    await client.storage
                        .from('activities')
                        .uploadBinary(
                            '/${client.auth.currentUser!.id}/activity/${inserted['id']}',
                            image!.value,
                            fileOptions: FileOptions(
                              contentType: 'image/$ext',
                            ))
                        .catchError((error) {
                      status = 2;

                      if (kDebugMode) {
                        print(error);
                      }

                      return '';
                    });
                  }

                  if (!mounted) {
                    return;
                  }

                  var message = 'Activity succesfully created';
                  LoadingStatus? newStatus = LoadingStatus.success;

                  if (status == 1) {
                    message = 'A problem ocurred creating the activity';
                    newStatus = null;
                  } else if (status == 2) {
                    message = 'A problem ocurred uploading the image, '
                        'but the activity was created';
                  }

                  setState(() {
                    loadingStatus = newStatus;
                  });

                  // ignore: use_build_context_synchronously
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
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
