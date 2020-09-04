
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/screens/ChatRoomScreen.dart';


class Home extends StatefulWidget
{

  String userName;
  String userEmail;
  
  Home({this.userName,this.userEmail});

  @override
  _HomeState createState() => _HomeState(userName,userEmail);
}

class _HomeState extends State<Home>
{

  String myName;
  String myEmail;
  
  _HomeState(String myName,String myEmail)
  {
    this.myName = myName;
    this.myEmail = myEmail;
  }

  String userID;

  bool isSearching = false;
  bool isFilteringData = false;

  String searchUser;
  String userPicture;
  String ChatRoomId;
  String lastMessage;
  String lastTime;

  bool firstRoom = false;
  bool secondRoom = false;
  bool noRoom = false;

  String times;

  final formKey = new GlobalKey<FormState>();
  TextEditingController userSearchController = TextEditingController();


  bool validateSearchBar()
  {
    final form = formKey.currentState;
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

  checkForChatRoomId(String myName,String myFriend) async
  {

    // Possible Chat Rooms
    String firstChatRoom = myName+'_'+myFriend;
    String secondChatRoom = myFriend+'_'+myName;

    var id1 = await Firestore.instance.collection('ChatRoom').document(firstChatRoom).get();

    if(id1.exists)
    {
      print('First Room Exists');
      ChatRoomId = firstChatRoom;
      firstRoom = true;
      return firstChatRoom;
    }

    if(!id1.exists)
    {
      var id2 = await Firestore.instance.collection('ChatRoom').document(secondChatRoom).get();

      if(id2.exists)
        {
          print('Second Room Exists');
          ChatRoomId = secondChatRoom;
          secondRoom = true;
          return secondChatRoom;
        }
      if(!id2.exists)
        {
          print('No ChatRoom Found!');
          lastMessage = 'No Conversation Exists';
          lastTime = '';
          ChatRoomId = null;
          noRoom = true;
          return ChatRoomId;
        }
    }
  }

  void signOut() async
  {
    await FirebaseAuth.instance.signOut();

    Firestore.instance.collection('Users').document(userID).updateData({'userStatus':'Offline'})
        .then((value) => print(myName + 'Goes Offline'));

    // go back to login screen
    Navigator.of(context).pop();
  }

  BoxDecoration memberStatusDecoration()
  {
    return BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.all(Radius.circular(10)),
      border: Border.all(color: Colors.pinkAccent,width: 0.8)
    );
  }

  @override
  void initState()
  {
    super.initState();

    lastMessage = 'Last Message';
    lastTime = '12:00 PM';

  }

  @override
  Widget build(BuildContext context)
  {

    if(userID != null)
    {
      Firestore.instance.collection('Users').document(userID).updateData({'userStatus':'ACTIVE'})
          .then((value) => print(myName + ' Comes Online'));
    }

    return Scaffold(

      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Chats',style: TextStyle(fontSize: 27,fontWeight: FontWeight.bold),),
            Text(myName,style: TextStyle(color: Colors.green),),
            IconButton(
              icon: Icon(Icons.exit_to_app,color: Colors.pinkAccent,),
              onPressed: ()
              {
                signOut();
              },
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),

      body: GestureDetector(
        onTap: ()
        {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: Color(0xff041A37),
          alignment: Alignment.center,
          child: ListView(
            children: <Widget>
            [

              Container(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                child: Form(
                  key: formKey,
                  child: Row(
                    children: <Widget>[

                      Expanded(
                        child: TextFormField(
                          style: TextStyle(color: Colors.white,fontSize: 17,decoration: TextDecoration.none),
                          controller: userSearchController,
                          validator: (value)
                          {
                            return value.isEmpty ? 'Enter member name... !' : null;
                          },
                          decoration: InputDecoration(
                              fillColor: Color(0xff011126),
                              filled: true,
                              hintText: 'Search Members',
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
                          autofocus: false,
                        ),
                      ),

                      SizedBox(width: 5,),

                      Container(
                        padding: EdgeInsets.all(3.5),
                        child: isFilteringData == false
                          ? IconButton(icon: Icon(Icons.search,color: Colors.white,),
                          onPressed: ()
                          {
                            if(validateSearchBar())
                              {
                                setState(()
                                {
                                  searchUser = userSearchController.text;
                                  isFilteringData = true;
                                });
                              }
                          },
                          )
                          : IconButton(icon: Icon(Icons.cancel,color: Colors.white,),
                          onPressed: ()
                          {

                            setState(()
                            {
                              searchUser = null;
                              userSearchController.clear();
                              isFilteringData = false;
                            });
                          },
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                          border: Border.all(width: 0.9,),
                          color: Color(0xff011126),
                        ),
                      )

                    ],
                  ),
                ),
              ),

              SizedBox(height: 10,),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                child: isFilteringData
                    ? StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection('Users').where('name', isEqualTo: '$searchUser').snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> querySnapshot)
                  {
                    if(querySnapshot.hasError)
                    {
                      return Center(child: Text('There is Some Error'));
                    }
                    if(querySnapshot.connectionState == ConnectionState.waiting)
                    {
                      return Center(child: CircularProgressIndicator());
                    }
                    else
                    {
                      final list = querySnapshot.data.documents;

                      return Container(
                        height: MediaQuery.of(context).size.height * 0.75,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: ListView.builder(
                          itemBuilder: (context,index)
                          {
                            String memberName = list[index]['name'];
                            String memberEmail = list[index]['email'];
                            String memberPicture = list[index]['image'];

                            userPicture = memberPicture;

                            // not to show my Name in Member List
                            if(memberEmail == myEmail)
                            {
                              return Container();
                            }

                            return GestureDetector(
                              onTap: ()
                              {
                                Navigator.push(context, MaterialPageRoute(builder: (_)=>ChatRoomScreen(myName: myName,friendPicture: memberPicture,friendName: memberName,friendEmail: memberEmail,)));
                              },
                              child: Container(
                                decoration:  BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(7)),
                                  border: Border.all(width: 0.9,),
                                  color: Color(0xff011126),
                                ),
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.all(7),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[

                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.purple,
                                      backgroundImage: memberPicture == null
                                          ? Image.asset('images/profile.png')
                                          : NetworkImage(memberPicture),
                                    ),

                                    SizedBox(width: 18,),

                                    Expanded(
                                      child: Container(
                                        //color: Colors.white,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[

                                            Container(
                                              //color:Colors.red,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(memberName,style: TextStyle(color: Colors.white,
                                                      fontWeight: FontWeight.bold,fontSize: 15),),
                                                  SizedBox(height: 4,),
                                                  Text('Hello Brother .... ',style: TextStyle(color: Colors.white54),),
                                                ],
                                              ),
                                            ),

                                            Container(
                                              padding: EdgeInsets.only(bottom: 18),
                                              //color: Colors.green,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: <Widget>[

                                                  Text('06:10 PM',style: TextStyle(color: Colors.white54),),

                                                ],
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                    )

                                  ],
                                ),
                              ),
                            );

                          },
                          itemCount: list.length,

                        ),
                      );

                    }
                  },
                )
                    : StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection('Users').snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> querySnapshot)
                  {
                    if(querySnapshot.hasError)
                      {
                        return Center(child: Text('There is Some Error'));
                      }
                    if(querySnapshot.connectionState == ConnectionState.waiting)
                      {
                        return Center(child: CircularProgressIndicator());
                      }
                    else
                      {
                        final list = querySnapshot.data.documents;

                        return Container(
                          height: MediaQuery.of(context).size.height * 0.75,
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: ListView.builder(
                            itemBuilder: (context,index)
                            {
                               String memberName = list[index]['name'];
                               String memberEmail = list[index]['email'];
                               String memberPicture = list[index]['image'];
                               String memberStatus = list[index]['userStatus'];

                               String Room1 = myName+'_'+memberName;
                               String Room2 = memberName+'_'+myName;

                               userPicture = memberPicture;

                               firstRoom = false;
                               secondRoom = false;

                               // not to show my Name in Member List
                               if(memberEmail == myEmail)
                                 {
                                   userID = list[index].documentID;
                                   return Container();
                                 }

                                 return GestureDetector(
                                   onTap: ()
                                   {
                                    Navigator.push(context, MaterialPageRoute(builder: (_)=>
                                        ChatRoomScreen(myName: myName,friendPicture: memberPicture,
                                          friendName: memberName,friendEmail: memberEmail,)));
                                   },
                                   child: FutureBuilder(
                                     future: checkForChatRoomId(myName, memberName),
                                     builder: (context,snapshot)
                                     {
                                       return Container(
                                         height: 55,
                                         decoration:  BoxDecoration(
                                           borderRadius: BorderRadius.all(Radius.circular(7)),
                                           border: Border.all(width: 0.9,),
                                           color: Color(0xff011126),
                                         ),
                                         margin: EdgeInsets.only(bottom: 10),
                                         padding: EdgeInsets.all(7),
                                         child: StreamBuilder<QuerySnapshot>(
                                           stream: firstRoom == true
                                               ? Firestore.instance.collection('ChatRoom').where('chatRoomId', isEqualTo: '$Room1').snapshots()
                                               : Firestore.instance.collection('ChatRoom').where('chatRoomId', isEqualTo: '$Room2').snapshots(),
                                           builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> querySnapshot)
                                           {
                                             if(querySnapshot.hasError)
                                             {
                                               return Center(child: Text('There is Some Error'));
                                             }
                                             if(querySnapshot.connectionState == ConnectionState.waiting)
                                             {
                                               return Center(child: CircularProgressIndicator());
                                             }
                                             else
                                             {

                                              // print('Final Data -----> ' + ChatRoomId.toString());
                                              // print('Friend Name ---> '+memberName);

                                               final list = querySnapshot.data.documents;

                                               return ListView.builder(
                                                 itemBuilder: (context,index)
                                                 {

                                                   String lastMessage = list[index]['lastMessage'];
                                                   lastTime = list[index]['lastMessageTime'];

                                                 //  print('Message ---> '+lastMessage);
                                                 //  print('Time --->'+lastTime);

                                                   return Row(
                                                     crossAxisAlignment: CrossAxisAlignment.start,
                                                     children: <Widget>[

                                                       CircleAvatar(
                                                         radius: 20,
                                                         backgroundColor: Colors.purple,
                                                         backgroundImage: memberPicture == null
                                                             ? Image.asset('images/profile.png')
                                                             : NetworkImage(memberPicture),
                                                       ),

                                                       SizedBox(width: 18,),

                                                       Expanded(
                                                         child: Container(
                                                           //color: Colors.white,
                                                           child: Row(
                                                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                             children: <Widget>[

                                                               Container(
                                                                 //color:Colors.red,
                                                                 child: Column(
                                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                                   children: <Widget>
                                                                   [

                                                                     Text(memberName,style: TextStyle(color: Colors.white,
                                                                         fontWeight: FontWeight.bold,fontSize: 15),),

                                                                     SizedBox(height: 4,),

                                                                     Container(
                                                                        height: 20,
                                                                        width: 180,
                                                                             child: Text(lastMessage,style:
                                                                             TextStyle(color: Colors.white54),)
                                                                     ),

                                                                     // Text(lastMessage,style: TextStyle(color: Colors.white54),),
                                                                   ],
                                                                 ),
                                                               ),

                                                               Container(

                                                                 //color: Colors.green,
                                                                 child: Column(
                                                                   crossAxisAlignment: CrossAxisAlignment.end,
                                                                   children: <Widget>
                                                                   [
                                                                     Container(
                                                                       padding: EdgeInsets.only(left: 7,right: 7,bottom: 1,top: 1),
                                                                       child: Text(memberStatus,style: TextStyle(color: Colors.pinkAccent,
                                                                           fontWeight: FontWeight.bold,fontSize: 12),),
                                                                       decoration: memberStatusDecoration(),
                                                                     ),
                                                                     SizedBox(height: 6,),
                                                                     Text(lastTime,style: TextStyle(color: Colors.white54),),
                                                                   ],
                                                                 ),
                                                               ),

                                                             ],
                                                           ),
                                                         ),
                                                       )

                                                     ],
                                                   );

                                                 },
                                                 itemCount: list.length,

                                               );

                                             }
                                           },
                                         ),

                                       );
                                     },
                                   ),
                               );

                            },
                            itemCount: list.length,

                          ),
                        );

                      }
                  },
                ),
              )

            ],
          ),// color for search bar Color(0xff00122A)
        ),
      ),

    );
  }
}
