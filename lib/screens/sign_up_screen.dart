import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_chat_app/screens/home_screen.dart';
import 'package:new_chat_app/screens/login_screen.dart';
import 'package:new_chat_app/widgets/my_elivated_button.dart';
import 'package:new_chat_app/widgets/my_text_form_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _image;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  bool _isLoading = false;
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      }
    });
  }

  Future<String?> _uploadImage(File? image) async {
    if (image == null) return null;

    try {
      final ref = _storage
          .ref()
          .child('user_images')
          .child('${_auth.currentUser!.uid}.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      log('Image upload failed: $e'); // for me
      Fluttertoast.showToast(msg: "Image upload failed"); // for user
      return null;
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
                email: _emailController.text, password: _passController.text);

        if (_image == null) {
          Fluttertoast.showToast(msg: 'Please select an image');
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final imageUrl = await _uploadImage(_image!);
        if (imageUrl == null) {
          setState(() {
            _isLoading = false;
          });
          return;
        }

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': _nameController.text,
          'email': _emailController.text,
          'imageUrl': imageUrl,
        });

        Fluttertoast.showToast(msg: 'Sign Up Success');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      } catch (e) {
        log(e.toString());
        Fluttertoast.showToast(msg: e.toString());
        // showDialog(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     title: Text('Sign Up Error'),
        //     content: Text(e.toString()),
        //   ),
        // );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 174, 156, 255),
                  Color.fromARGB(255, 250, 193, 212),
                  Color(0xFFB39DDB),
                  Color.fromARGB(255, 119, 91, 167),
                  Color.fromARGB(255, 147, 39, 148),
                ],
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 60, bottom: 23),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Create\nAccount',
                      style: TextStyle(
                        fontSize: 50,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300,
                    ),
                    child: _image == null
                        ? Center(
                            child: Icon(Icons.add_a_photo,
                                color: Colors.white, size: 30),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(150),
                            child: Image.file(
                              _image!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 30),
                MyTextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your name";
                    }
                    return null;
                  },
                  text: 'Name',
                ),
                MyTextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    }
                    return null;
                  },
                  text: 'Email',
                ),
                MyTextFormField(
                  obscureText: _obscureText,
                  onIconPressed: _togglePasswordVisibility,
                  controller: _passController,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    }
                    return null;
                  },
                  text: 'Password',
                ),
                SizedBox(height: 25),
                MyElivatedButton(
                  text: 'Create Account',
                  onPressed: _isLoading ? null : _signUp,
                ),
                if (_isLoading) CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 15),
                Text(
                  '_______OR_______',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Do you already have an account?',
                      style: TextStyle(
                          color: Color.fromARGB(255, 122, 0, 102),
                          fontSize: 16),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        ' Login',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
