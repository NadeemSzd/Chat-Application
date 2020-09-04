import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'LoginScreen.dart';
import 'home.dart';



class RegistrationScreen extends StatefulWidget
{
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
{

  File sampleImage;
  String imageUrl;

  String userStatus;

  final formkey = new GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _nameController = TextEditingController();

  bool isFormatCorrect = true;

  Future<bool> registerUser(String email, String pass, String name) async
  {
     FirebaseAuth auth = FirebaseAuth.instance;

    try
    {
      AuthResult result = await auth.createUserWithEmailAndPassword(email: email, password: pass);

      FirebaseUser user = result.user;

      UserUpdateInfo updateInfo = UserUpdateInfo();
      updateInfo.displayName = name;

      user.updateProfile(updateInfo);
      return true;
    }
    catch(e)
    {
      print("***************************");
      print(e);
      print("***************************");
      return false;
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

  void getImage() async
  {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(()
    {
      sampleImage = tempImage;
    });

  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(

      appBar: AppBar(
        title: Text('Registration',style: TextStyle(fontSize: 25),),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
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

                Stack(
                  children: <Widget>[

                    Align(
                      alignment: Alignment.center,
                      child:ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          child: sampleImage == null
                                 ? Image.asset('images/profile.png',height: 150,)
                                 : Image.file(sampleImage,height: 150.0,width: 150.0,fit: BoxFit.fill,)

                      ),

                    ),

                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: EdgeInsets.only(top: 115,left: 150),
                        child: IconButton(
                          icon: Icon(Icons.photo_camera,color: Colors.pink,size: 28,),
                          onPressed: ()
                          {
                            getImage();
                          },
                        ),
                      ),
                    )

                  ],
                ),

                SizedBox(height: 20,),

                TextFormField(
                  style: TextStyle(color: Colors.white,fontSize: 17,decoration: TextDecoration.none),
                  controller: _nameController,
                  validator: (value)
                  {
                    return value.isEmpty ? 'Name Required' : null;
                  },
                  decoration: InputDecoration(
                      fillColor: Color(0xff011126),
                      filled: true,
                      prefixIcon: Container(width: 65,
                      child: Icon(Icons.account_circle,color: Colors.white38,)),
                      hintText: 'Name',
                      hintStyle: TextStyle(color: Colors.white38),
                      labelStyle: TextStyle(fontSize: 18),
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

                SizedBox(height: 15,),

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

                SizedBox(height: 18,),

                isFormatCorrect == false ?
                Container(
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  child: Text('Email or Password format incorrect !!!',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                ) : Container(),

                SizedBox(height: 40,),

                SizedBox(
                  height: 50,
                  child: RaisedButton(
                    child: Text('Register',style: TextStyle(fontSize: 22),),
                    color: Colors.pink,
                    textColor: Colors.white,
                    onPressed: () async
                    {

                     if(validateForm())
                       {
                         final email = _emailController.text.toString().trim();
                         final password = _passController.text.toString().trim();
                         final name = _nameController.text.toString().trim();

                         bool result = await registerUser(email, password, name);

                         if(result)
                         {

                           final StorageReference reference = FirebaseStorage.instance.ref().child('Chat Images');

                           var timekey = DateTime.now();
                           final StorageUploadTask uploadTask = reference.child(timekey.toString()+"jpg").putFile(sampleImage);
                           imageUrl = await(await uploadTask.onComplete).ref.getDownloadURL();
                           print('Image Url ----> '+imageUrl);

                           userStatus = 'Active';

                           Map<String,String> data =
                           {
                             'name' : name,
                             'email' : email,
                             'image' : imageUrl,
                             'userStatus': userStatus,
                           };

                           Firestore.instance.collection('Users').add(data).catchError((e){print(e.toString());});

                           _nameController.clear();
                           _emailController.clear();
                           _passController.clear();

                           Navigator.push(context, MaterialPageRoute(builder: (_)=>Home(userName: name,userEmail: email,)));

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
                      //Navigator.push(context, MaterialPageRoute(builder: (_)=>LoginScreen()));
                      Navigator.of(context).pop();
                    },
                    child: Text('Already have an Account ?',style: TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.bold),),
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
