import 'package:flutter/material.dart';

showMySnackBar({
  required BuildContext context,
  required String message,
  Color? color,
}) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(
    SnackBar(
      content: Text(message,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
      backgroundColor: color ?? Colors.green,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,  
    ),
  );
}