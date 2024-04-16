import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_feed/enums/loading_status.dart';
import 'package:supabase_feed/widgets/retry_data_fetch.dart';
import 'package:supabase_feed/widgets/sized_progress_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final client = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _fields = {};
  var _showPassword = false;
  var _loadingStatus = LoadingStatus.loading;
  LoadingStatus? _updateLoadingStatus;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = client.auth.currentUser;
    if (user == null || user.isAnonymous) return;

    if (user.userMetadata?['password_set'] == true) {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    var fail = false;
    final data = await client
        .from('profiles')
        .select('username, full_name')
        .eq('id', user.id)
        .single()
        .catchError((error) {
      fail = true;

      if (kDebugMode) {
        print(error);
      }

      return <String, dynamic>{};
    });

    setState(() {
      _fields['username'] = data['username'] ?? '';
      _fields['fullname'] = data['full_name'] ?? '';
      _loadingStatus = fail ? LoadingStatus.fail : LoadingStatus.success;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingStatus == LoadingStatus.loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.blueAccent[700],
          ),
        ),
      );
    } else if (_loadingStatus == LoadingStatus.fail) {
      return Scaffold(
        body: Center(
          child: RetryDataFetch(
            label: 'Unable to load user data',
            onPressed: () {
              setState(() {
                _loadingStatus = LoadingStatus.loading;
              });

              _loadUserData();
            },
          ),
        ),
      );
    }

    final fieldStyle = TextStyle(
      color: Colors.blueAccent[700],
      fontSize: 18,
    );

    final fieldDecoration = InputDecoration(
      labelStyle: TextStyle(
        letterSpacing: 1,
        fontWeight: FontWeight.w500,
        color: Colors.blueAccent[700],
      ),
      prefixIconColor: Colors.blueAccent[700],
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blueAccent[700]!),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blueAccent[700]!),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red[200]!),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red[200]!),
      ),
      errorStyle: TextStyle(
        color: Colors.redAccent[200],
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Expanded(
                    child: Text(
                      'Almost there...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  TextFormField(
                    initialValue: _fields['username'],
                    autocorrect: false,
                    enableSuggestions: false,
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (newValue) => _fields['username'] = newValue!,
                    cursorColor: Colors.blueAccent[700],
                    cursorErrorColor: Colors.red[200],
                    style: fieldStyle,
                    decoration: fieldDecoration.copyWith(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value?.isEmpty != false) {
                        return 'The username must be inserted';
                      } else if (!RegExp(r'^[a-z]\w{3,20}$').hasMatch(value!)) {
                        return 'Invalid username provided';
                      }

                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: _fields['fullname'],
                    autocorrect: false,
                    enableSuggestions: false,
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (newValue) =>
                        _fields['fullname'] = newValue!.trim(),
                    cursorColor: Colors.blueAccent[700],
                    cursorErrorColor: Colors.red[200],
                    style: TextStyle(
                      color: Colors.blueAccent[700],
                    ),
                    decoration: fieldDecoration.copyWith(
                      labelText: 'Full name',
                      prefixIcon: const Icon(Icons.list_alt_sharp),
                    ),
                    validator: (value) {
                      if (value?.isEmpty != false) {
                        return 'The full name must be inserted';
                      } else if (value!.trim().length <= 3) {
                        return 'Invalid full name provided';
                      }

                      return null;
                    },
                  ),
                  TextFormField(
                    autocorrect: false,
                    enableSuggestions: false,
                    onSaved: (newValue) => _fields['password'] = newValue!,
                    obscureText: !_showPassword,
                    cursorColor: Colors.blueAccent[700],
                    cursorErrorColor: Colors.red[200],
                    style: TextStyle(
                      color: Colors.blueAccent[700],
                    ),
                    decoration: fieldDecoration.copyWith(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIconColor: Colors.blueAccent[700],
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty != false) {
                        return 'The password must be inserted';
                      }

                      return null;
                    },
                  ),
                  const Expanded(flex: 3, child: SizedBox()),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      _formKey.currentState!.save();
                      final userID = client.auth.currentUser!.id;

                      setState(() {
                        _updateLoadingStatus = LoadingStatus.loading;
                      });

                      // 0 -> no errors
                      var status = 0;
                      await client
                          .from('profiles')
                          .update({
                            "username": _fields['username'],
                            "full_name": _fields['fullname'],
                          })
                          .eq('id', userID)
                          .catchError((error) {
                            status = 1;

                            if (kDebugMode) {
                              print(error);
                            }
                          });

                      if (status == 0) {
                        try {
                          await client.auth.updateUser(UserAttributes(
                            password: _fields['password'],
                            data: {'password_set': true},
                          ));
                        } catch (ex) {
                          status = 2;

                          if (kDebugMode) {
                            print(ex);
                          }
                        }
                      }

                      if (!mounted) {
                        return;
                      }

                      setState(() {
                        if (status == 0) {
                          _updateLoadingStatus = LoadingStatus.success;
                        } else {
                          _updateLoadingStatus = LoadingStatus.fail;
                        }
                      });

                      var message = 'Information updated!';
                      if (status == 1) {
                        message = 'Unable to update information';
                      } else if (status == 2) {
                        message = 'Unable to update password';
                      }

                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                            SnackBar(content: Text(message)),
                          )
                          .closed
                          .then((value) {
                        if (status == 0) {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent[700],
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(40),
                    ),
                    icon: _updateLoadingStatus != LoadingStatus.loading
                        ? const Icon(Icons.save)
                        : const SizedProgressIndicator(
                            color: Colors.white,
                            diameter: 20,
                            strokeWidth: 2,
                          ),
                    label: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
