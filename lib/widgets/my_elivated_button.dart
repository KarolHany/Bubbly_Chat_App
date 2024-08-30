import 'package:flutter/material.dart';

class MyElivatedButton extends StatelessWidget {
  const MyElivatedButton({super.key, required this.text , required this.onPressed});
  final String text;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        width: 300,
        child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                Color.fromARGB(255, 174, 156, 255),
              ),
            ),
            onPressed: onPressed,
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            )));
  }
}
