import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_feed/enums/loading_status.dart';
import 'package:supabase_feed/widgets/datetime_form_field.dart';
import 'package:supabase_feed/widgets/retry_data_fetch.dart';
import 'package:supabase_feed/widgets/sized_progress_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageActivity extends StatefulWidget {
  const ManageActivity({super.key});

  @override
  State<ManageActivity> createState() => _ManageActivityState();
}

class _ManageActivityState extends State<ManageActivity> {
  final client = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _datetimeController = TextEditingController();

  var loadingStatus = LoadingStatus.loading;
  int? entryID;
  Map<String, dynamic> fields = {};
  LoadingStatus? editLoadingStatus;

  void fetchData() async {
    await Future.delayed(Duration.zero);

    if (!mounted) {
      return;
    }

    int id;

    if (entryID != null) {
      id = entryID!;
    } else {
      var args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args == null) {
        return;
      }

      id = args['id'];
    }

    var fail = false;
    final result = await client
        .from('activity')
        .select()
        .eq('id', id)
        .single()
        .catchError((error) {
      if (kDebugMode) {
        print(error);
      }

      fail = true;
      return <String, dynamic>{};
    });

    setState(() {
      entryID = id;
      fields = result;
      loadingStatus = fail ? LoadingStatus.fail : LoadingStatus.success;
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
        child: RetryDataFetch(
          label: 'Unable to load the required information',
          onPressed: () {
            setState(() {
              loadingStatus = LoadingStatus.loading;
              fields = {};
            });

            fetchData();
          },
          color: Colors.blueAccent[700],
        ),
      );
    } else {
      body = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: fields['title'],
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
                initialValue: fields['detail'],
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
                initialDate: DateTime.parse(fields['date']),
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
                icon: editLoadingStatus == LoadingStatus.loading
                    ? const SizedProgressIndicator(
                        diameter: 25,
                        strokeWidth: 3,
                        color: Colors.white,
                      )
                    : const Icon(Icons.edit),
                label: const Text('Update'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18, letterSpacing: 1),
                ),
                onPressed: () {
                  if (editLoadingStatus != null ||
                      _formKey.currentState?.validate() != true) {
                    return;
                  }

                  _formKey.currentState?.save();
                  var fail = false;

                  setState(() {
                    editLoadingStatus = LoadingStatus.loading;
                  });

                  client
                      .from('activity')
                      .update(fields)
                      .eq('id', entryID!)
                      .catchError((error) {
                    fail = true;

                    if (kDebugMode) {
                      print(error);
                    }
                  }).then((value) {
                    var message = 'Activity succesfully updated';
                    LoadingStatus? newStatus = LoadingStatus.success;

                    if (fail) {
                      message = 'A problem ocurred updating the activity';
                      newStatus = null;
                    }

                    setState(() {
                      editLoadingStatus = newStatus;
                    });

                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(
                          content: Text(message),
                        ))
                        .closed
                        .then((value) {
                      if (editLoadingStatus == LoadingStatus.success) {
                        Navigator.pop(context);
                      }
                    });
                  });
                },
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  var result = await showModalBottomSheet(
                    enableDrag: false,
                    isDismissible: false,
                    context: context,
                    builder: (context) {
                      var isDeleting = false;

                      return StatefulBuilder(
                        builder: (context, setState) {
                          var sheetBody = isDeleting
                              ? const PopScope(
                                  canPop: false,
                                  child: CircularProgressIndicator(),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 80),
                                      child: Text(
                                        'Are you sure you want to delete this Activity?',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              isDeleting = true;
                                            });

                                            var deleteFail = false;
                                            client
                                                .from('activity')
                                                .delete()
                                                .eq('id', entryID!)
                                                .catchError((error) {
                                              deleteFail = true;

                                              if (kDebugMode) {
                                                print(error);
                                              }
                                            }).then((value) => Navigator.pop(
                                                    context, !deleteFail));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.redAccent[700],
                                            foregroundColor: Colors.white,
                                          ),
                                          icon: const Icon(Icons.delete),
                                          label: const Text('Delete'),
                                        ),
                                      ],
                                    )
                                  ],
                                );

                          return SizedBox(
                            height: 200,
                            child: Center(
                              child: sheetBody,
                            ),
                          );
                        },
                      );
                    },
                  );

                  if (result == null || !mounted) {
                    return;
                  }

                  var message = 'The Activity was deleted successfully';

                  if (result == false) {
                    message = 'There was a problem deleting the Activity';
                  }

                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(
                        content: Text(message),
                      ))
                      .closed
                      .then((value) {
                    if (result == true) {
                      Navigator.pop(context);
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  backgroundColor: Colors.redAccent[700],
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18, letterSpacing: 1),
                ),
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Activity'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent[700],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: body,
      ),
    );
  }
}
