import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/screens/LoginScreen.dart';
import 'package:my_chat_app/screens/RegistrationScreen.dart';
import 'package:my_chat_app/screens/home.dart';


void main()=>runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Chat Application',
  home: LoginScreen(),
  theme: ThemeData(
    primaryColor: Color(0xff041A37),
  ),
));