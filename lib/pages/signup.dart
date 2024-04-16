import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_feed/enums/loading_status.dart';
import 'package:supabase_feed/widgets/sized_progress_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final client = Supabase.instance.client;
  final _controller = TextEditingController();
  late final StreamSubscription<AuthState> _authSubscription;
  LoadingStatus? loadingStatus;

  @override
  void initState() {
    super.initState();

    _authSubscription = client.auth.onAuthStateChange.listen((event) {
      if (event.session != null) {
        Navigator.pushNamedAndRemoveUntil(context, '/account', (route) => false);
        return;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign-up'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent[700],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Please insert an email for your account:',
                style: TextStyle(
                  letterSpacing: 1,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.emailAddress,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                  suffixIcon: loadingStatus == LoadingStatus.loading
                      ? SizedProgressIndicator(
                          padding: 8,
                          color: Colors.blueAccent[700],
                        )
                      : IconButton(
                          onPressed: () async {
                            final email = _controller.text.trim();

                            if (!RegExp(r'^[a-z](\.?\w)*@\w(\.?\w)*\.\w+$')
                                .hasMatch(email)) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Invalid email'),
                              ));

                              return;
                            }

                            setState(() {
                              loadingStatus = LoadingStatus.loading;
                            });

                            try {
                              await client.auth.signInWithOtp(
                                email: email,
                                emailRedirectTo:
                                    'io.gomod.supabasefeed://login-callback/',
                              );

                              if (mounted) {
                                setState(() {
                                  loadingStatus = LoadingStatus.success;
                                });

                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Check your inbox'),
                                  ),
                                );
                              }
                            } on AuthException catch (error) {
                              if (kDebugMode) {
                                print(error);
                              }

                              if (!mounted) return;

                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error.message),
                                  backgroundColor:
                                      // ignore: use_build_context_synchronously
                                      Theme.of(context).colorScheme.error,
                                ),
                              );
                            } catch (error) {
                              if (kDebugMode) {
                                print(error);
                              }

                              if (!mounted) return;

                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'An error occurred; please retry'),
                                  backgroundColor:
                                      // ignore: use_build_context_synchronously
                                      Theme.of(context).colorScheme.error,
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  loadingStatus = LoadingStatus.fail;
                                });
                              }
                            }
                          },
                          icon: const Icon(Icons.send_rounded),
                          color: Colors.blueAccent[700],
                        ),
                  labelStyle: TextStyle(
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueAccent[700],
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent[700]!),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent[700]!),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
