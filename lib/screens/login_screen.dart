import 'package:chautari_kurakani/widgets/my_floating_button.dart';
import 'package:chautari_kurakani/widgets/my_outline_button.dart';
import 'package:chautari_kurakani/widgets/my_text_button.dart';
import 'package:chautari_kurakani/widgets/my_text_field.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginForm = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF76C05D),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40,),
              
              // Image.asset('assets/images/white_half_logo.png',height: 100,width: 100,),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 26,
                      spreadRadius: 1,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/white_half_logo.png',
                  height: 100,
                  width: 100,
                ),
              ),
          
              SizedBox(height: 20,),
          
              Text("ChautariKuraKani",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                     shadows: [
                        Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: Offset(2, 3),
                        ),
                      ],
                  ),),
          
              SizedBox(height: 5,),
          
              Text("Chautarimah Sabai Kura",style: TextStyle(color: Colors.white,fontSize: 20),),
          
               SizedBox(height: 30,),
          
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: Container(
                  // height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3E3E3),
                    borderRadius: BorderRadius.circular(20), 
                    boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: Offset(0, 2)
                    )]
                  ),
                 child: Form(
                  key: _loginForm,
          
                   child: Padding(
                     padding: const EdgeInsets.fromLTRB(15, 20, 15, 30),
                     child: Column(
                      children: [
                        Text("Login",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
                        SizedBox(height: 28,),
                        MyTextfield(
                          controller: emailController, 
                          text: "Email", hintText: "Email",
                          errorText: "Please enter your email",
                          prefixIcon: Icons.email,
                        ),
                        SizedBox(height: 10,),
                        MyTextfield(
                          controller: passwordController, 
                          text: "Password", 
                          hintText: "Password",
                          errorText: "Please enter your password",
                          prefixIcon: Icons.lock,
                          isPassword: true,
                        ),
          
                        SizedBox(height: 30,),
                        MyFloatingButton(onPressed: (){}, text: "Log in",color: const Color.fromARGB(255, 229, 163, 32),),
          
                        SizedBox(height: 30,),
          
                        // MyTextButton(onPressed: (){}, text: "Forgot Password?",textColor: const Color.fromARGB(255, 83, 126, 160),),
                        MyTextButton(onPressed: (){}, text: "Forgot Password?",textColor: const Color.fromARGB(255, 63, 124, 42),),
          
                        SizedBox(height: 30,),
                     
                        MyOutlinedButton(onPressed: (){}, text: "Create new account",borderColor: const Color(0xFF76C05D),textColor: const Color.fromARGB(255, 113, 113, 113),),
                        
                      ],
                     ),
                   ),
                 ), 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}