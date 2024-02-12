import 'package:chatting_app/widgets/input_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebase = FirebaseAuth.instance;
final _firebaseStorage = FirebaseStorage.instance;
final _firebaseFirestore = FirebaseFirestore.instance;

class AutScreen extends StatefulWidget {
  const AutScreen({super.key});

  @override
  State<AutScreen> createState() {
    return _AutScreenState();
  }
}

class _AutScreenState extends State<AutScreen> {
  var _login = true;
  final _formKey = GlobalKey<FormState>();
  var _passwordValue = '';
  var _emailValue = '';
  var _usernameValue = '';
  File? _selectedImage;
  var _isSigning = false;
  void _submit() async {
    final valid = _formKey.currentState!.validate();
    if (!_login && _selectedImage == null) {
      return;
    }
    if (valid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isSigning = true;
        });
        if (_login) {
          final response = await _firebase.signInWithEmailAndPassword(
              email: _emailValue, password: _passwordValue);
        } else {
          final response = await _firebase.createUserWithEmailAndPassword(
              email: _emailValue, password: _passwordValue);
          final imgStorage = _firebaseStorage
              .ref()
              .child('the_images')
              .child('${response.user!.uid}.jpg');
          await imgStorage.putFile(_selectedImage!);
          final imgUrl = await imgStorage.getDownloadURL();
          await _firebaseFirestore
              .collection('users')
              .doc(response.user!.uid)
              .set({
            'userName': _usernameValue,
            'email': _emailValue,
            'image': imgUrl,
          });
        }
      } on FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use') {
          //
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message ?? 'error')));
        setState(() {
          _isSigning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    top: 30,
                    bottom: 15,
                    left: 15,
                    right: 15,
                  ),
                  width: 250,
                  child: Image.asset('assets/images/chatt.png'),
                ),
                Card(
                  margin: const EdgeInsets.all(15),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!_login)
                                InputImage(
                                  onPickImage: (theImage) {
                                    _selectedImage = theImage;
                                  },
                                ),
                              if (!_login)
                                TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'Username'),
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value.trim().length <= 4) {
                                      return 'Username must be at least 5 characters';
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    _usernameValue = newValue!;
                                  },
                                ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: ' Email',
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      !value.contains('@')) {
                                    return 'Check your email';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  _emailValue = newValue!;
                                },
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 6) {
                                    return 'Password should contain 6 characters';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) =>
                                    _passwordValue = newValue!,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (_isSigning) const CircularProgressIndicator(),
                              if (!_isSigning)
                                ElevatedButton(
                                    onPressed: _submit,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary),
                                    child: Text(_login ? 'Login' : 'Signup')),
                              if (!_isSigning)
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _login = !_login;
                                      });
                                    },
                                    child: Text(_login
                                        ? 'I dont have an account'
                                        : 'I have an account'))
                            ],
                          )),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
