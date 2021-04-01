import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'Decrypt.dart';
import 'package:flutter/material.dart';
import 'package:jc_messenger/models/chat.dart';
import 'package:jc_messenger/models/fid.dart';
import 'package:jc_messenger/models/muser.dart';
import './profile.dart';
import './sign_in.dart';
import 'package:uuid/uuid.dart';

class Chat extends StatefulWidget {
  final String chatId;
  final String proid;

  Chat({this.chatId, this.proid});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Muser user, user2;
  bool isUnlock = false;
  TextEditingController commentController = TextEditingController();
  String mid = Uuid().v4();
  ScrollController _myController = ScrollController();
  TextEditingController sub = TextEditingController();

  String enc1 = "";
  String key1 = "";

  List<Chats> textss = [];

  @override
  void initState() {
    super.initState();
    getdetails();
    changeinbox();
  }

  changeinbox() async {
    QuerySnapshot snapshot = await chatRef
        .document(widget.proid)
        .collection(widget.chatId)
        .orderBy("timestamp", descending: false)
        .getDocuments();

    snapshot.documents.forEach((doc) {
      Chats x = Chats.fromDocument(doc);
      chatRef
          .document(widget.proid)
          .collection(widget.chatId)
          .document(x.mid)
          .updateData({"isSeen": true});
      mref
          .document(widget.proid)
          .collection("messages")
          .document(x.mid)
          .updateData({"isSeen": true});

      chatRef
          .document(widget.chatId)
          .collection(widget.proid)
          .document(x.mid)
          .updateData({"isRecieve": true});
      mref
          .document(widget.chatId)
          .collection("messages")
          .document(x.mid)
          .updateData({"isRecieve": true});
    });
  }

  getdetails() async {
    DocumentSnapshot doc = await musersRef.document(widget.chatId).get();
    DocumentSnapshot doc2 = await musersRef.document(widget.proid).get();

    setState(() {
      user = Muser.fromDocument(doc);
      user2 = Muser.fromDocument(doc2);
    });
  }

  String funny1(String x) {
    String a, b, c;
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

  buildtexts() {
    return StreamBuilder(
        stream: chatRef
            .document(widget.proid)
            .collection(widget.chatId)
            .orderBy("timestamp", descending: false)
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
          List<Chats> texts = [];
          snapshot.data.documents.forEach((doc) {
            Chats y = Chats.fromDocument(doc);
            texts.add(y);
          });
          textss = texts;
          return ListView(
            shrinkWrap: true,
            controller: _myController,
            children: List.generate(
              texts.length,
              (index) {
                return Container(
                  padding: EdgeInsets.only(
                      top: 8,
                      bottom: 8,
                      left: (widget.proid == texts[index].senderId) ? 0 : 24,
                      right: (widget.proid == texts[index].senderId) ? 24 : 0),
                  alignment: (widget.proid == texts[index].senderId)
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: GestureDetector(
                    onLongPress: () {
                      return showDialog(
                          context: context,
                          builder: (context) {
                            return SimpleDialog(
                              title: Text("OPTIONS"),
                              children: <Widget>[
                                SimpleDialogOption(
                                    onPressed: () {
                                      if (currentUser.id ==
                                          texts[index].senderId) {
                                        Navigator.pop(context);
                                        chatRef
                                            .document(texts[index].senderId)
                                            .collection(texts[index].recieverId)
                                            .document(texts[index].mid)
                                            .get()
                                            .then((doc) {
                                          if (doc.exists) {
                                            doc.reference.delete();
                                          }
                                        });
                                        mref
                                            .document(texts[index].senderId)
                                            .collection("messages")
                                            .document(texts[index].mid)
                                            .get()
                                            .then((doc) {
                                          if (doc.exists) {
                                            doc.reference.delete();
                                          }
                                        });
                                        return showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                                  title: new Text(
                                                      "TEXT  DELETED !!!",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "JustAnotherHand",
                                                          fontSize: 30.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white)),
                                                  content: Text(
                                                      "However ${texts[index].recieverName} can still see that message!!!",
                                                      style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white)),
                                                ));
                                      } else {
                                        Navigator.pop(context);
                                        chatRef
                                            .document(texts[index].recieverId)
                                            .collection(texts[index].senderId)
                                            .document(texts[index].mid)
                                            .get()
                                            .then((doc) {
                                          if (doc.exists) {
                                            doc.reference.delete();
                                          }
                                        });
                                        mref
                                            .document(texts[index].recieverId)
                                            .collection("messages")
                                            .document(texts[index].mid)
                                            .get()
                                            .then((doc) {
                                          if (doc.exists) {
                                            doc.reference.delete();
                                          }
                                        });
                                        return showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                                  title: new Text(
                                                      "TEXT  DELETED !!!",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "JustAnotherHand",
                                                          fontSize: 30.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white)),
                                                  content: Text(
                                                      "However ${texts[index].senderName} can still see that message!!!",
                                                      style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white)),
                                                ));
                                      }
                                    },
                                    child: Text(
                                      'Delete Text',
                                      style: TextStyle(color: Colors.red),
                                    )),
                                SimpleDialogOption(
                                    onPressed: () {
                                      if (currentUser.id ==
                                          texts[index].senderId) {
                                        Navigator.pop(context);
                                        chatRef
                                            .document(texts[index].senderId)
                                            .collection(texts[index].recieverId)
                                            .document(texts[index].mid)
                                            .get()
                                            .then((doc) {
                                          if (doc.exists) {
                                            doc.reference.delete();
                                          }
                                        });
                                        chatRef
                                            .document(texts[index].recieverId)
                                            .collection(texts[index].senderId)
                                            .document(texts[index].mid)
                                            .get()
                                            .then((doc) {
                                          if (doc.exists) {
                                            doc.reference.delete();
                                          }
                                        });
                                        mref
                                            .document(texts[index].senderId)
                                            .collection("messages")
                                            .document(texts[index].mid)
                                            .get()
                                            .then((doc) {
                                          if (doc.exists) {
                                            doc.reference.delete();
                                          }
                                        });
                                        mref
                                            .document(texts[index].recieverId)
                                            .collection("messages")
                                            .document(texts[index].mid)
                                            .get()
                                            .then((doc) {
                                          if (doc.exists) {
                                            doc.reference.delete();
                                          }
                                        });
                                        return showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                                  title: new Text(
                                                      "TEXT  UNSENT !!!",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "JustAnotherHand",
                                                          fontSize: 30.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white)),
                                                ));
                                      } else {
                                        Navigator.pop(context);
                                        return showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                                  title: new Text(
                                                      "YOU AIN'T THE SENDER!!!",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "JustAnotherHand",
                                                          fontSize: 30.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white)),
                                                ));
                                      }
                                    },
                                    child: Text(
                                      'Unsend Text',
                                      style: TextStyle(color: Colors.red),
                                    )),
                                SimpleDialogOption(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel')),
                              ],
                            );
                          });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      margin: (widget.proid == texts[index].senderId)
                          ? EdgeInsets.only(left: 30)
                          : EdgeInsets.only(right: 30),
                      padding: EdgeInsets.only(
                          top: 17, bottom: 17, left: 20, right: 20),
                      decoration: BoxDecoration(
                          borderRadius: (widget.proid == texts[index].senderId)
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(23),
                                  topRight: Radius.circular(23),
                                  bottomLeft: Radius.circular(23))
                              : BorderRadius.only(
                                  topLeft: Radius.circular(23),
                                  topRight: Radius.circular(23),
                                  bottomRight: Radius.circular(23)),
                          gradient: LinearGradient(
                            colors: (widget.proid == texts[index].senderId)
                                ? [
                                    Colors.white,
                                    Colors.white,
                                  ]
                                : [
                                    const Color(0x1AFFFFFF),
                                    const Color(0x1AFFFFFF)
                                  ],
                          )),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.only(top: 10.0),
                              child: SelectableText(
                                  (isUnlock == false)
                                      ? encrypt(texts[index].message)
                                      : texts[index].message,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: (widget.proid ==
                                              texts[index].senderId)
                                          ? Colors.black
                                          : Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold))),
                          Padding(
                              padding: EdgeInsets.only(top: 12.0),
                              child: Text(
                                "${funny(texts[index].timestamp.toDate().toString())}\n${funny1(texts[index].timestamp.toDate().toString())}",
                                style: TextStyle(
                                    color:
                                        (widget.proid == texts[index].senderId)
                                            ? Colors.black54
                                            : Colors.grey),
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  addToRoom(String a, String b) async {
    List<String> f = [];
    print(a);
    DocumentSnapshot doc = await musersRef.document(a).get();
    Muser user = Muser.fromDocument(doc);

    if (user.ids.length == 0) {
      setState(() {
        f.add(b);
      });

      musersRef.document(a).updateData({"Ids": FieldValue.arrayUnion(f)});
    } else {
      Fid fid = Fid.fromDocument(doc);

      setState(() {
        if (!fid.fid.contains(b)) fid.fid.add(b);
      });

      musersRef.document(a).updateData({"Ids": FieldValue.arrayUnion(fid.fid)});
    }
  }

  addcomment() {
    if (commentController.text.isNotEmpty) {
      DateTime ts = DateTime.now();
      //update sender's database
      chatRef
          .document(widget.proid)
          .collection(widget.chatId)
          .document(mid)
          .setData({
        "mid": mid,
        "message": commentController.text,
        "senderId": widget.proid,
        "senderName": user2.displayName,
        "recieverId": widget.chatId,
        "senderPhoto": user2.photoUrl,
        "recieverPhoto": user.photoUrl,
        "recieverName": user.displayName,
        "timestamp": ts,
        "isSeen": false,
      });
      addToRoom(widget.proid, widget.chatId);
      //update reciever's database
      chatRef
          .document(widget.chatId)
          .collection(widget.proid)
          .document(mid)
          .setData({
        "mid": mid,
        "message": commentController.text,
        "senderId": widget.proid,
        "senderName": user2.displayName,
        "senderPhoto": user2.photoUrl,
        "recieverId": widget.chatId,
        "recieverPhoto": user.photoUrl,
        "recieverName": user.displayName,
        "timestamp": ts,
        "isSeen": false,
        "isRecieve": false
      });
      addToRoom(widget.chatId, widget.proid);

      mref.document(widget.proid).collection("messages").document(mid).setData({
        "mid": mid,
        "message": commentController.text,
        "senderId": widget.proid,
        "senderName": user2.displayName,
        "senderPhoto": user2.photoUrl,
        "recieverId": widget.chatId,
        "recieverPhoto": user.photoUrl,
        "recieverName": user.displayName,
        "timestamp": ts,
        "isSeen": false,
        "isRecieve": false
      });

      mref
          .document(widget.chatId)
          .collection("messages")
          .document(mid)
          .setData({
        "mid": mid,
        "message": commentController.text,
        "senderId": widget.proid,
        "senderName": user2.displayName,
        "senderPhoto": user2.photoUrl,
        "recieverId": widget.chatId,
        "recieverPhoto": user.photoUrl,
        "recieverName": user.displayName,
        "timestamp": ts,
        "isSeen": false,
        "isRecieve": false
      });

      setState(() {
        mid = Uuid().v4();
        commentController.text = "";
      });
    }
  }

  String encrypt(String value) {
    int fl, hl, fl1, fl2, hl1, hl2;
    var str = value;
    var str1, str2, str3;
    print(str);

    fl = str.length;
    hl = fl ~/ 2;

    str1 = str.substring(0, hl);
    if (fl % 2 == 0)
      str2 = str.substring(hl, fl);
    else {
      str2 = str.substring(hl + 1, fl);
      str3 = str.substring(hl, hl + 1);
    }

    var str4, str5, str6;
    fl1 = str1.length;
    hl1 = fl1 ~/ 2;

    str4 = str1.substring(0, hl1);
    if (fl1 % 2 == 0)
      str5 = str1.substring(hl1, fl1);
    else {
      str5 = str1.substring(hl1 + 1, fl1);
      str6 = str1.substring(hl1, hl1 + 1);
    }

    var str7, str8, str9;
    fl2 = str2.length;
    hl2 = fl1 ~/ 2;

    str7 = str2.substring(0, hl2);
    if (fl2 % 2 == 0)
      str8 = str2.substring(hl2, fl2);
    else {
      str8 = str2.substring(hl2 + 1, fl2);
      str9 = str2.substring(hl2, hl2 + 1);
    }

    if (fl1 % 2 == 0)
      str1 = str5.split('').reversed.join() + str4;
    else
      str1 = str5.split('').reversed.join() + str6 + str4;

    if (fl2 % 2 == 0)
      str2 = str8.split('').reversed.join() + str7;
    else
      str2 = str8.split('').reversed.join() + str9 + str7;

    if (fl % 2 == 0)
      str = str2 + str1;
    else
      str = str2 + str3 + str1;

    print(str);

    var enc = "";
    var key = "";

    for (int i = 0; i < fl; i++) {
      var d, e, s = 0;
      d = str.codeUnitAt(i);

      while (d > 0) {
        e = d % 10;
        s += e;
        d = (d / 10).toInt();
      }
      key += s.toString() + "-";
      var x;
      x = str.codeUnitAt(i) + ((i + 1) * s);
      x = x % 94;
      x = x + 32;

      enc += String.fromCharCode(x);
    }

    key = key.substring(0, (key.length - 1));
//enc=enc+"\n\nKEY:\n\n"+key;

    enc1 = enc;
    key1 = key;

    return enc + key;
  }

  @override
  Widget build(BuildContext context) {
    Timer(Duration(milliseconds: 500),
        () => _myController.jumpTo(_myController.position.maxScrollExtent));
    if (user == null)
      return Scaffold(
          backgroundColor: Colors.blue[900],
          body: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 10.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.black),
              )));
    else
      return WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignIn(),
            ),
          );
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      if (isUnlock == false)
                        showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                actions: [
                                  FlatButton(
                                    child: Text("Unlock",
                                        style: TextStyle(color: Colors.blue)),
                                    onPressed: () async {
                                      if (sub.text.trim() == currentUser.pwd) {
                                        setState(() {
                                          isUnlock = true;
                                        });
                                        Navigator.pop(context);

                                        showDialog(
                                            context: context,
                                            builder: (_) {
                                              return AlertDialog(
                                                  title: Text(
                                                "Unlocked",
                                                textAlign: TextAlign.center,
                                              ));
                                            });
                                      } else {
                                        Navigator.pop(context);
                                        showDialog(
                                            context: context,
                                            builder: (_) {
                                              return AlertDialog(
                                                  title: Text(
                                                "Incorrect Pass Code",
                                                textAlign: TextAlign.center,
                                              ));
                                            });
                                      }

                                      sub.text = "";
                                    },
                                  ),
                                  FlatButton(
                                    child: Text("Cancel",
                                        style: TextStyle(color: Colors.red)),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      sub.text = "";
                                    },
                                  ),
                                ],
                                title: new Text("Enter Pass Code",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    )),
                                content: Container(
                                  height: 120,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Container(
                                          child: TextFormField(
                                            controller: sub,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: "Pass Code",
                                              labelStyle: TextStyle(
                                                fontSize: 15.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                      else
                        setState(() {
                          isUnlock = false;
                        });
                    },
                    child: Icon(
                        (isUnlock == false) ? Icons.lock : Icons.lock_open)),
              ],
              centerTitle: true,
              title: FlatButton(
                child:
                    Text("${user.displayName}", style: TextStyle(fontSize: 20)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Profile(profileId: user?.id),
                    ),
                  );
                },
              )),
          body: Column(
            children: <Widget>[
              Expanded(child: buildtexts()),
              Container(
                color: Colors.grey[900],
                child: ListTile(
                  title: TextFormField(
                    autofocus: false,
                    onTap: () {
                      Timer(
                          Duration(milliseconds: 500),
                          () => _myController
                              .jumpTo(_myController.position.maxScrollExtent));
                    },
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    controller: commentController,
                    decoration: InputDecoration(
                        labelText: "Send a text...\n",
                        labelStyle: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.normal)),
                  ),
                  trailing: OutlineButton(
                      onPressed: () {
                        addcomment();
                      },
                      borderSide: BorderSide.none,
                      child: Icon(
                        Icons.send,
                        size: 30,
                      )),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
