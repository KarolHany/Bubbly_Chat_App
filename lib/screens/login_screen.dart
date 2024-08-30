import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_chat_app/provider/auth_provider.dart';
import 'package:new_chat_app/screens/home_screen.dart';
import 'package:new_chat_app/screens/sign_up_screen.dart';
import 'package:new_chat_app/widgets/my_elivated_button.dart';
import 'package:new_chat_app/widgets/my_text_form_field.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailControll = TextEditingController();
  final TextEditingController _passControll = TextEditingController();
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
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
              ])),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 150),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text('Login',
                        style: TextStyle(
                          fontSize: 55,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ))),
              ),
              Spacer(
                flex: 1,
              ),
              MyTextFormField(
                controller: _emailControll,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please Enter Your Email";
                  }
                  return null;
                },
                text: 'Email',
              ),
              MyTextFormField(
                obscureText: _obscureText,
                onIconPressed: _togglePasswordVisibility,
                controller: _passControll,
                keyboardType: TextInputType.visiblePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please Enter Your Email";
                  }
                  return null;
                },
                text: 'Password',
              ),
              SizedBox(
                height: 25,
              ),
              MyElivatedButton(
                text: 'Login',
                onPressed: () async {
                  try {
                    await authProvider.signIn(
                        _emailControll.text, _passControll.text);
                    Fluttertoast.showToast(
                        msg:
                            'Login Success'); // showing simple feedback or alerts without interrupting the user experience.
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ));
                  } catch (e) {
                    print(e);
                  }
                },
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                '_______OR_______',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have any account ? ',
                    style: TextStyle(
                        color: Color.fromARGB(255, 122, 0, 102), fontSize: 16),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          ));
                    },
                    child: Text(
                      ' Create Account',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
              Spacer(
                flex: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
