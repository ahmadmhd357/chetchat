import 'dart:io';

import 'package:chetchat/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  String _enteredEmail = '';
  String _enteredPassword = '';
  File? _selectedImage;
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;
  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || !_isLogin && _selectedImage == null) {
      return;
    }
    _formKey.currentState!.save();
    try {
      setState(() {
        _isLoading = true;
      });
      if (_isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredentionals =
            await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentionals.user!.email}.jpg');
        await storageRef.putFile(_selectedImage!);
        final imageURl = await storageRef.getDownloadURL();
        FirebaseFirestore.instance.collection("users").doc(userCredentionals.user!.uid).set({
        "id":userCredentionals.user!.uid,
        "email": userCredentionals.user!.email,
        "username":"to be set...",
        "image": imageURl
        },);
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Something went wrong, try again later'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
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
          const Padding(padding: EdgeInsets.all(20)),
          if (!_isLogin)
            UserImagePicker(
              onPickImage: (pickedImage) => _selectedImage = pickedImage,
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
          if (_isLoading) const CircularProgressIndicator(),
          if (!_isLoading)
            ElevatedButton(
              onPressed: _submit,
              child: Text(_isLogin ? 'Login' : 'Sign up'),
            ),
          if (!_isLoading)
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
