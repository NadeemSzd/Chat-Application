import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/screens/RegistrationScreen.dart';

import 'home.dart';



class LoginScreen extends StatefulWidget
{
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
{

  final formkey = new GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  bool isFormatCorrect = true;

  Future<FirebaseUser> userLogin(String email, String pass) async
  {
    FirebaseAuth auth = FirebaseAuth.instance;

    try
    {

      AuthResult result = await auth.signInWithEmailAndPassword(email: email, password: pass);

      FirebaseUser user = result.user; // currently logged-in user

      return user;
    }
    catch(e)
    {
      print("***************************");
      print(e);
      print("***************************");
      return null;
    }

  }

  bool validateForm()
  {
    final form = formkey.currentState;

    if(form.validate())
    {
      form.save();
      return true;
    }
    else
    {
      return false;
    }

  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(

        appBar: AppBar(
          title: Text('Login',style: TextStyle(fontSize: 25),),
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: true,
        ),

        body: Container(
          color: Color(0xff041A37),
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Center(
            child: Form(
              key: formkey,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>
                [

                  TextFormField(
                    style: TextStyle(color: Colors.white,fontSize: 17,decoration: TextDecoration.none),
                    controller: _emailController,
                    validator: (value)
                    {
                      return value.isEmpty ? 'Email Required' : null;
                    },
                    decoration: InputDecoration(
                        fillColor: Color(0xff011126),
                        filled: true,
                        prefixIcon: Container(width:65,child: Icon(Icons.email,color: Colors.white38,),),
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.white38),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 18),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                            borderSide: BorderSide(color: Colors.pink,width: 1)
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                        )
                    ),
                  ),

                  SizedBox(height: 15,),

                  TextFormField(
                    obscureText: true,
                    style: TextStyle(color: Colors.white,fontSize: 17,decoration: TextDecoration.none),
                    controller: _passController,
                    validator: (value)
                    {
                      return value.isEmpty ? 'Password Required' : null;
                    },
                    decoration: InputDecoration(
                        fillColor: Color(0xff011126),
                        filled: true,
                        prefixIcon: Container(width: 65,child: Icon(Icons.vpn_key,color: Colors.white38,),),
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.white38),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 18),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                            borderSide: BorderSide(color: Colors.pink,width: 1)
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7)
                        )
                    ),
                  ),

                  SizedBox(height: 20,),

                  isFormatCorrect == false ?
                  Container(
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Text('Email or Password incorrect !!!',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                  ) : Container(),

                  SizedBox(height: 50,),

                  SizedBox(
                    height: 50,
                    child: RaisedButton(
                      child: Text('Login',style: TextStyle(fontSize: 22),),
                      color: Colors.pink,
                      textColor: Colors.white,
                      onPressed: () async
                      {

                        if(validateForm())
                        {
                          final email = _emailController.text.toString().trim();
                          final password = _passController.text.toString().trim();

                          FirebaseUser user = await userLogin(email, password);

                          if(user != null)
                          {
                             print('UserName ------> '+user.displayName);
                             _emailController.clear();
                             _passController.clear();

                             Navigator.push(context, MaterialPageRoute(builder: (_)=>Home(userName: user.displayName,userEmail: email,)));
                          }
                          else
                          {

                            setState(()
                            {
                               isFormatCorrect = false;
                            });

                            print("*****************************");
                            print("--------- Error ---------");
                            print("*****************************");
                          }
                        }
                        else
                        {
                          print("*******************");
                          print('Form Has Some Problems ...');
                          print("*******************");
                        }

                      },
                    ),
                  ),

                  SizedBox(height: 20,),

                  Center(
                    child: GestureDetector(
                      onTap: ()
                      {
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>RegistrationScreen()));
                      },
                      child: Text('Create an Account ?',style: TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.bold),),
                    ),
                  )

                ],
              ),
            ),
          ),
        )
    );
  }
}
