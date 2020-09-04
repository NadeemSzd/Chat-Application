
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


class ChatRoomScreen extends StatefulWidget
{
  String myName;
  String friendName;
  String friendEmail;
  String friendPicture;

  ChatRoomScreen({this.myName,this.friendPicture,this.friendName,this.friendEmail});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState(myName: myName,friendPicture: friendPicture,friendName: friendName,friendEmail: friendEmail);
}

class _ChatRoomScreenState extends State<ChatRoomScreen>
{

  String myName;
  String friendName;
  String friendEmail;
  String friendPicture;

  _ChatRoomScreenState({this.myName,this.friendPicture,this.friendName,this.friendEmail});

  String ChatRoomId;
  String ChatRoomName1;
  String ChatRoomName2;

  String lastMessage;
  String lastTime;

  TextEditingController sendMessageController = TextEditingController();

  File sampleImage;
  String imageUrl;


  BoxDecoration myMessageDecoration()
  {
    return BoxDecoration(
      color: Colors.purple,
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),topRight: Radius.circular(10))
    );
  }

  BoxDecoration friendMessageDecoration()
  {
    return BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(10),topLeft: Radius.circular(10))
    );
  }

  @override
  void initState()
  {
    super.initState();

    ChatRoomName1 = myName +'_'+ friendName;
    ChatRoomName2 = friendName +'_'+ myName;

  }

  checkForChatRoomId(String chatRoomId1,String chatRoomId2) async
  {

    var id1 = await Firestore.instance.collection('ChatRoom').document(chatRoomId1).get();

    var id3 = await Firestore.instance.collection('ChatRoom').where('name',isEqualTo: chatRoomId1).get();

    if(id1.exists)
    {
      print('Exists');
      ChatRoomId = chatRoomId1;
      print(ChatRoomId);
      return chatRoomId1;
    }

    if(!id1.exists)
    {
      print('Not exists');
      ChatRoomId = chatRoomId2;
      return chatRoomId2;
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

  createChatRoom()
  {
    Map<String,String> data =
    {
      'user1' : myName,
      'user2' : friendName,
      'chatRoomId': ChatRoomId,
      'lastMessage' : lastMessage,
      'lastMessageTime' : lastTime
    };

    Firestore.instance.collection('ChatRoom').document(ChatRoomId)
        .setData(data).catchError((e){print(e.toString());});
  }


  _buildMessageComposer()
  {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 15.0,right: 12),
      height: 70.0,
      child: Row(
        children: <Widget>[

          /*IconButton(
            icon: Icon(Icons.photo),
            color: Theme.of(context).primaryColor,
            iconSize: 25.0,
            onPressed: ()
            {
                getImage();
            },
          ),*/

          Expanded(
            child: TextField(
              controller: sendMessageController,
              decoration: InputDecoration.collapsed(
                  hintText: 'Send a message ... '
              ),
            ),
          ),

          IconButton(
            icon: Icon(Icons.send),
            color: Theme.of(context).primaryColor,
            iconSize: 25.0,
            onPressed: () async
            {
              String message = sendMessageController.text;

              if(message.isNotEmpty)
                {

                  // used to send an image to others
                  /*final StorageReference reference = FirebaseStorage.instance.ref().child('Chat Images');

                  var timekey = DateTime.now();
                  final StorageUploadTask uploadTask = reference.child(timekey.toString()+"jpg").putFile(sampleImage);
                  imageUrl = await(await uploadTask.onComplete).ref.getDownloadURL();
                  print('Image Url ----> '+imageUrl);*/

                  var dbDateTime = DateTime.now();
                  // var date = DateFormat('MMM d, yyyy').format(dbDateTime);
                  var time = DateFormat('hh: mm aaa').format(dbDateTime);
                  var exactTime = DateTime.now().millisecondsSinceEpoch;

                  Map<String,dynamic> sendMessage =
                  {
                    'message' : message,
                    'sender' : myName,
                    'time' : time,
                    'exactTime' : exactTime
                  };

                  lastMessage = message;
                  lastTime = time;

                  createChatRoom();

                  Firestore.instance.collection('ChatRoom').document(ChatRoomId)
                      .collection('chats').add(sendMessage).then((value) => sendMessageController.clear());

                  Firestore.instance.collection('ChatRoom').document(ChatRoomId)
                      .updateData({'lastMessage' : lastMessage,'lastMessageTime':lastTime}).then((value)
                  {
                    print('Last Message ----> '+lastMessage);
                    print('Last MessageTime ---> '+lastTime);
                  });
                }

            },
          )
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context)
  {

    return Scaffold(

      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 15,
              backgroundImage: friendPicture == null
                  ? Image.asset('images/profile.png')
                  : NetworkImage(friendPicture),
            ),
            SizedBox(width: 20,),
            Text(friendName),
          ],
        ),
        elevation: 0,
      ),

      body: GestureDetector(
        onTap: ()
        {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: <Widget>[
            
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                color: Color(0xff041A37),
                child: FutureBuilder(
                  future: checkForChatRoomId(ChatRoomName1, ChatRoomName2),
                  builder: (context,snapshot)
                  {

                    return StreamBuilder<QuerySnapshot>(
                            stream: Firestore.instance.collection('ChatRoom').document(ChatRoomId).collection('chats').orderBy('exactTime').snapshots(),
                            builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> querySnapshot)
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

                     // print('Chat Room Name ----> ' + ChatRoomId.toString());

                      final list = querySnapshot.data.documents;
                      return Container(
                        child: ListView.builder(
                          itemBuilder: (context,index)
                          {

                            String message = list[index]['message'];
                            String messageSender = list[index]['sender'];
                            String time = list[index]['time'];

                            String messageId = list[index].documentID;

                            return messageSender == myName
                                ? Dismissible(
                                 key: Key(messageId),
                                 direction: DismissDirection.startToEnd,
                                 onDismissed: (direction)
                                 {
                                  Firestore.instance.collection('ChatRoom').document(ChatRoomId).collection('chats').document(messageId).delete();
                                 },
                                 background: Container(padding: EdgeInsets.only(left: 25),color: Colors.pink,child: Icon(Icons.delete_forever,color: Colors.black,),alignment: Alignment.centerLeft,),
                                 child: Container(
                                  decoration: myMessageDecoration(),
                                  padding: EdgeInsets.only(left: 15,top: 5,bottom: 5,right: 10),
                                  margin: EdgeInsets.only(bottom: 10,left: 120),
                                  child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: <Widget>[
                                    Text(message,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>
                                      [
                                        Text(time,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold,color: Colors.white70),),
                                      ],
                                    ),
                                  ],
                                ),),
                            )
                                : Container(
                                  decoration: friendMessageDecoration(),
                                  padding: EdgeInsets.only(left: 15,top: 5,bottom: 5,right: 10),
                                  margin: EdgeInsets.only(bottom: 10,right: 120),
                                  child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: <Widget>[
                                    Text(message,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>
                                      [
                                        Text(time,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold,color: Colors.white70),),
                                      ],
                                    ),
                                  ],
                                ));
                          },
                          itemCount: list.length,
                        ),
                      );
                    }
                            },
                       );

                  },
                ),
              ),
            ),
            _buildMessageComposer()
          ],
        ),
      ),

    );
  }
}
