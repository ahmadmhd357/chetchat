import 'package:flutter/material.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  String _enteredEmail = '';
  String _enteredPassword = '';
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  void _submit() {
    bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              _isLogin ? "Sign in" : "Sign up",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Email Address',
              labelStyle: TextStyle(color: Colors.white),
              suffixIcon: Icon(
                Icons.email_rounded,
                color: Colors.white,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textCapitalization: TextCapitalization.none,
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty ||
                  !value.contains('@')) {
                return 'Please Enter correct email address.';
              }
              return null;
            },
            onSaved: (newValue) {
              
                _enteredEmail = newValue!;
             
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.white),
              suffixIcon: Icon(
                Icons.password,
                color: Colors.white,
              ),
            ),
            keyboardType: TextInputType.visiblePassword,
            autocorrect: false,
            textCapitalization: TextCapitalization.none,
            obscureText: true,
            validator: (value) {
              if (value == null || value.trim().length < 6) {
                return "The password should be at least 6 charachter long!";
              }
              return null;
            },
            onSaved: (newValue) {
              
                _enteredPassword = newValue!;
              
            },
          ),
          const SizedBox(
            height: 40,
          ),
          ElevatedButton(
            onPressed: _submit,
            child: Text(_isLogin ? 'Login' : 'Sign up'),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(
                _isLogin
                    ? "don't have an account, click to sign up"
                    : "already have an account, click to sign in",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}