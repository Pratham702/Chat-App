import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fireStore = FirebaseFirestore.instance;
User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = '/chat';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();
  String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    final user = await _auth.currentUser;
    try {
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  // void getMessages() async{
  //   final messages = await _fireStore.collection('messages').get();
  //   for(var message in messages.docs){
  //     print(message.data());
  //   }
  // }

  void messageStream() async {
    await for (var snapshot in _fireStore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // messageStream();
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _fireStore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.docs.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message['text'];
          final messageSender = message['sender'];

          final currentUser = loggedInUser.email;

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
          );

          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe});
  final String sender;
  final String text;
  bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          Material(
            elevation: 5,
            borderRadius: isMe
                ? BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30))
                : BorderRadius.only(
              topRight: Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flash_chat/constants.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// final _firestore=FirebaseFirestore.instance;
// User loggedInUser;
//
// class ChatScreen extends StatefulWidget {
//   static String id='/chat';
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final messageTextController=TextEditingController();
//   final _auth=FirebaseAuth.instance;
//   String messagetext;
//
//   @override
//   void initState() {
//     super.initState();
//     getCurrentUser();
//   }
//   void getCurrentUser() async{
//       try{
//         final user= await _auth.currentUser;
//         if(user!=null) {
//           loggedInUser = user;
//           print(loggedInUser.email);
//         }
//       }
//       catch(e)
//     {
//       print(e);
//     }
//   }
// // void getMessages() async{
// //
// //     final messages= await _firestore.collection('messages').get();
// //     for(var message in messages.docs)
// //       print(message.data());
// // }
//   void messageStream() async{
//
//     await for(var snapshot in _firestore.collection('messages').snapshots()) {
//       for (var message in snapshot.docs) {
//         print(message.data());
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: null,
//         actions: <Widget>[
//
//           IconButton(
//               icon: Icon(Icons.close),
//               onPressed: () {
//                 //Implement logout functionality
//                 // messageStream();
//                 _auth.signOut();
//                 Navigator.pop(context);
//               }),
//         ],
//         title: Text('⚡️Chat'),
//         backgroundColor: Colors.lightBlueAccent,
//       ),
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             MessageStream(),
//             Container(
//               decoration: kMessageContainerDecoration,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   Expanded(
//                     child: TextField(
//                       controller: messageTextController,
//                       onChanged: (value) {
//                         //Do something with the user input.
//                         messagetext=value;
//                       },
//                       decoration: kMessageTextFieldDecoration,
//                     ),
//                   ),
//                   FlatButton(
//                     onPressed: () {
//                       //Implement send functionality.
//                       messageTextController.clear();
//                       _firestore.collection('messages').add({
//                         'text':messagetext,
//                         'sender':loggedInUser.email,
//                       });
//                     },
//                     child: Text(
//                       'Send',
//                       style: kSendButtonTextStyle,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class MessageStream extends StatelessWidget {
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _firestore.collection('messages').snapshots(),
//       // ignore: missing_return
//       builder:(context,snapshot){
//         if(!snapshot.hasData) {
//           return Center(
//             child: CircularProgressIndicator(
//               backgroundColor: Colors.lightBlueAccent,
//             ),
//           );
//         }
//         final messages = snapshot.data.docChanges.reversed;
//         List<MessageBubble> messageBubbles=[];
//         for(var message in messages){
//           final messagetext= message.doc['text'];
//           final messageSender = message.doc['sender'];
//           final currentUser=loggedInUser.email;
//           if(currentUser==messageSender){
//
//           }
//           final messageBubble= MessageBubble(text: messagetext,sender:messageSender,isMe: currentUser==messageSender, );
//           messageBubbles.add(messageBubble);
//
//         }
//         return Expanded(
//           child: ListView(
//             reverse: true,
//             padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
//             children: messageBubbles,
//           ),
//         );
//
//       },
//     );
//   }
// }
//
// class MessageBubble extends StatelessWidget {
//   MessageBubble({this.sender,this.text,this.isMe});
//  final String sender;
//  final String text;
//  final bool isMe;
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding:  EdgeInsets.all(10.0),
//       child: Column(
//         crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
//         children: [
//           Text(sender,
//           style: TextStyle(
//             fontSize: 12.0,
//             color: Colors.black54,
//           ),),
//           Material(
//             borderRadius: isMe?BorderRadius.only(
//               bottomLeft: Radius.circular(30.0),
//               bottomRight: Radius.circular(30.0),
//               topLeft: Radius.circular(30.0)
//             ):BorderRadius.only(
//                 bottomLeft: Radius.circular(30.0),
//                 bottomRight: Radius.circular(30.0),
//                 topRight: Radius.circular(30.0)
//             ),
//             color: isMe?Colors.lightBlueAccent:Colors.white,
//             child: Padding(
//               padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
//               child: Text(
//                 '$text ',
//                 style: TextStyle(
//                   color: isMe?Colors.white:Colors.black54,
//                   fontSize: 15.0,
//                 ),),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
