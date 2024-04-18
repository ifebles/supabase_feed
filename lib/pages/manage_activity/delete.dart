import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteActivity {
  static Future<bool?> showBuilder({
    required BuildContext context,
    required SupabaseClient client,
    required int entryID,
    required bool hasImage,
  }) {
    return showModalBottomSheet<bool?>(
      enableDrag: false,
      isDismissible: false,
      context: context,
      builder: (context) {
        var isDeleting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            var sheetBody = isDeleting
                ? PopScope(
                    canPop: false,
                    child: CircularProgressIndicator(
                      color: Colors.blueAccent[700],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 80),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              setState(() {
                                isDeleting = true;
                              });

                              var deleteFail = false;

                              if (hasImage) {
                                await client.storage.from('activities').remove([
                                  '${client.auth.currentUser!.id}/activity/$entryID',
                                ]).catchError((error) {
                                  deleteFail = true;

                                  if (kDebugMode) {
                                    print(error);
                                  }

                                  return <FileObject>[];
                                });
                              }

                              if (deleteFail) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Unable to remove image'),
                                    ),
                                  );
                                }

                                return;
                              }

                              await client
                                  .from('activity')
                                  .delete()
                                  .eq('id', entryID)
                                  .catchError((error) {
                                deleteFail = true;

                                if (kDebugMode) {
                                  print(error);
                                }
                              });

                              if (!context.mounted) return;
                              Navigator.pop(context, !deleteFail);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent[700],
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
  }
}
