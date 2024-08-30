import 'package:flutter/material.dart';

class MyTextFormField extends StatefulWidget {
   MyTextFormField({super.key, required this.text , required this.controller , required this.validator,required this.keyboardType ,  this.obscureText = false, this.onIconPressed});
  final String text;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final VoidCallback? onIconPressed; 

  @override
  State<MyTextFormField> createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // Shadow position
            ),
          ],
        ),
        child: TextFormField(

          obscureText: widget.obscureText,
          
          controller:widget.controller ,
          validator: widget.validator,
          keyboardType:widget.keyboardType ,
          decoration: InputDecoration(
            hintText: widget.text,
             suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(Icons.visibility),
                onPressed: widget.onIconPressed, // Handle icon press
              )
            : IconButton(
                icon: Icon(Icons.visibility_off),
                onPressed: widget.onIconPressed, // Handle icon press
              ),
            border: InputBorder.none, // Remove the default border
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
        ),
      ),
    );
  }
}
