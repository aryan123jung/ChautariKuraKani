import 'package:flutter/material.dart';

class MyFloatingButton extends StatelessWidget {
  const MyFloatingButton({
    super.key,
    required this.onPressed,
    required this.text, this.color = Colors.amber,
  });
  
  //On pressed callback
  final VoidCallback onPressed;
  final String text;
  final Color color;
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
        ),
        onPressed: onPressed, 
        child: Text(
          text,
          style: const TextStyle(color: Colors.black,fontSize: 20,),
        )),
    );
  }
}