import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jc_messenger/models/chat.dart';
import 'package:jc_messenger/models/muser.dart';
import 'package:jc_messenger/pages/sign_in.dart';
import 'package:jc_messenger/widgets/progress.dart';

import 'chat_box.dart';

class Inbox2 extends StatefulWidget {
  final Muser user;
  final List<dynamic> x;
  Inbox2({this.user, this.x});
  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox2> {
  bool isLoading = true;
  List<String> id = [];

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignIn()));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: mref
            .document(widget.user.id)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 10.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ));
          }
          List<Chats> ch = [];
          snapshot.data.documents.forEach((d) {
            Chats x = Chats.fromDocument(d);

            if (x.recieverId != widget.user.id) {
              if (!id.contains(x.recieverId)) {
                id.add(x.recieverId);
                ch.add(x);
              }
            } else {
              if (!id.contains(x.senderId)) {
                id.add(x.senderId);
                ch.add(x);
              }
            }
          });
          return ListView(
              children: List.generate(
            ch.length,
            (index) {
              return Container(
                color: (ch[index].isSeen == false &&
                        widget.user.id == ch[index].recieverId)
                    ? Colors.green[900].withOpacity(0.7)
                    : Theme.of(context).primaryColor.withOpacity(0.7),
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        showChat(context,
                            uid: widget.user.id,
                            profileId: (widget.user.id == ch[index].recieverId)
                                ? ch[index].senderId
                                : ch[index].recieverId);
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 25.0,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              (widget.user.photoUrl == ch[index].senderPhoto)
                                  ? CachedNetworkImageProvider(
                                      ch[index].recieverPhoto)
                                  : CachedNetworkImageProvider(
                                      ch[index].senderPhoto),
                        ),
                        title:
                            (widget.user.displayName == ch[index].recieverName)
                                ? ((ch[index].isSeen == false)
                                    ? Text(
                                        ch[index].senderName,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17),
                                      )
                                    : Text(
                                        ch[index].senderName,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 17),
                                      ))
                                : ((ch[index].isSeen == false)
                                    ? Text(
                                        ch[index].recieverName,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17),
                                      )
                                    : Text(
                                        ch[index].recieverName,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 17),
                                      )),
                        subtitle:
                            (widget.user.displayName == ch[index].senderName)
                                ? Text(
                                    "Your Message has been Sent",
                                    style: TextStyle(color: Colors.white38),
                                  )
                                : ((ch[index].isSeen == false &&
                                        widget.user.id == ch[index].recieverId)
                                    ? Text(
                                        "New Message",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Text(
                                        "You've Opened their message",
                                        style: TextStyle(
                                          color: Colors.white38,
                                        ),
                                      )),
                        trailing: (ch[index].isSeen == false &&
                                widget.user.id == ch[index].recieverId)
                            ? Text(
                                "${funny(ch[index].timestamp.toDate().toString())}\n${funny1(ch[index].timestamp.toDate().toString())}",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                "${funny(ch[index].timestamp.toDate().toString())}\n${funny1(ch[index].timestamp.toDate().toString())}",
                                style: TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                      ),
                    ),
                    Divider(
                      height: 2.0,
                      color: Colors.white54,
                    ),
                  ],
                ),
              );
            },
          ));
        });
  }
}

showChat(BuildContext context, {String profileId, String uid}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Chat(chatId: profileId, proid: uid),
    ),
  );
}

String funny1(String x) {
  String a, b, c, d;
  int q;

  a = x.substring(11, 16);
  int p = int.parse(a.substring(0, 2));
  if (p == 0) {
    p += 12;
    a = String.fromCharCode(p) + x.substring(13, 16) + " AM";
  } else if (p >= 1 && p <= 11) {
    a = a + " AM";
  } else if (p == 12) {
    a = a + " PM";
  } else if (p > 12) {
    p -= 12;
    a = String.fromCharCode(p) + x.substring(13, 16) + " PM";
  }

  b = x.substring(2, 4);
  q = int.parse(x.substring(5, 7));

  switch (q) {
    case 1:
      c = "Jan";
      break;
    case 2:
      c = "Feb";
      break;
    case 3:
      c = "Mar";
      break;
    case 4:
      c = "Apr";
      break;
    case 5:
      c = "May";
      break;
    case 6:
      c = "Jun";
      break;
    case 7:
      c = "Jul";
      break;
    case 8:
      c = "Aug";
      break;
    case 9:
      c = "Sep";
      break;
    case 10:
      c = "Oct";
      break;
    case 11:
      c = "Nov";
      break;
    case 12:
      c = "Dec";
      break;
    default:
      break;
  }

  b = x.substring(8, 10) + "-" + c + "-" + b;

  return b;
}

String funny(String x) {
  String a;
  print(x);
  a = x.substring(11, 16);
  print(a);
  int p = int.parse(a.substring(0, 2));
  print(p);
  if (p == 0) {
    p += 12;
    print(p);
    a = p.toString() + x.substring(13, 16) + " AM";
  } else if (p >= 1 && p <= 11) {
    a = a + " AM";
  } else if (p == 12) {
    a = a + " PM";
  } else if (p > 12) {
    p -= 12;
    print(p);
    a = p.toString() + x.substring(13, 16) + " PM";
  }

  print(a);
  return a;
}
