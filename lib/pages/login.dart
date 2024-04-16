import 'package:flutter/material.dart';
import 'package:supabase_feed/enums/loading_status.dart';
import 'package:supabase_feed/widgets/sized_progress_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final client = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _fields = {};
  var _showPassword = false;
  LoadingStatus? _loadingStatus;

  @override
  Widget build(BuildContext context) {
    const fieldStyle = TextStyle(
      color: Colors.white,
      fontSize: 18,
    );

    final fieldDecoration = InputDecoration(
      labelStyle: const TextStyle(
        letterSpacing: 1,
        color: Colors.white,
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red[200]!),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red[200]!),
      ),
      errorStyle: TextStyle(
        color: Colors.red[200],
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.blueAccent[700],
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Log in.',
                    style: TextStyle(
                      letterSpacing: 1,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (newValue) => _fields['email'] = newValue!,
                  cursorColor: Colors.white,
                  style: fieldStyle,
                  decoration: fieldDecoration.copyWith(
                    labelText: 'Email',
                  ),
                  validator: (value) {
                    if (value?.isEmpty != false) {
                      return 'The email must be inserted';
                    } else if (!RegExp(r'^[a-z](\.?\w)*@\w(\.?\w)*\.\w+$')
                        .hasMatch(value!)) {
                      return 'Invalid email provided';
                    }

                    return null;
                  },
                ),
                TextFormField(
                  autocorrect: false,
                  enableSuggestions: false,
                  onSaved: (newValue) => _fields['password'] = newValue!,
                  obscureText: !_showPassword,
                  cursorColor: Colors.white,
                  style: fieldStyle,
                  decoration: fieldDecoration.copyWith(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                      color: Colors.white,
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
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
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    _formKey.currentState!.save();

                    setState(() {
                      _loadingStatus = LoadingStatus.loading;
                    });

                    final response = await client.auth.signInWithPassword(
                      email: _fields['email'],
                      password: _fields['password']!,
                    );

                    if (!mounted) return;

                    if (response.session != null) {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pushReplacementNamed('/home');
                      return;
                    }

                    setState(() {
                      _loadingStatus = null;
                    });

                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Incorrect email/password')),
                    );
                  },
                  icon: const Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  label: _loadingStatus != LoadingStatus.loading
                      ? const Icon(Icons.send_rounded, size: 20)
                      : SizedProgressIndicator(
                          color: Colors.blueAccent[700],
                          strokeWidth: 2,
                          diameter: 20,
                        ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blueAccent[700],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text(
                    'Sign-up here',
                    style: TextStyle(
                      letterSpacing: 1,
                      color: Colors.blueAccent[100],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
