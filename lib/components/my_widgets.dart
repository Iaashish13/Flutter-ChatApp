import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  MyButton({required this.colour, required this.name, required this.onPressed});
  final Color colour;
  final String name;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Material(
        elevation: 5.0,
        color: colour,
        borderRadius: BorderRadius.circular(30),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 150.0,
          height: 52.0,
          child: Text(
            name,
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
