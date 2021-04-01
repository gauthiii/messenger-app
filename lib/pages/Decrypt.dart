import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jc_messenger/models/chat.dart';
import 'package:jc_messenger/pages/sign_in.dart';

class Decrypt extends StatefulWidget {
  final String c, d;
  final List<Chats> texts;
  final String proid;

  Decrypt({this.texts, this.proid, this.c, this.d});

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<Decrypt> {
  TextEditingController text = TextEditingController();

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Decrypt Message"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      "ENTER PASSCODE",
                      style: TextStyle(
                          fontSize: 25.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        controller: text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Passcode",
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: "Enter your Passcode",
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // ignore: missing_return
                    setState(() {
                      if (text.text == "") {
                        showDialog(
                            context: context,
                            builder: (_) => new AlertDialog(
                                  title: new Text("INCORRECT  PASSCODE !!!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: "JustAnotherHand",
                                          fontSize: 30.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  content: Text("Passcode can't be empty",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ));
                      } else if (text.text != widget.c) {
                        return showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                  title: new Text("INCORRECT PASSCODE !!!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: "JustAnotherHand",
                                          fontSize: 30.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  // content:  Text("You gotta follow atleast one user to see the timeline.Find some users to follow.Don't be a loner dude!!!!",style:TextStyle(fontSize: 17, fontWeight: FontWeight.bold,color: Colors.white)),
                                ));
                      } else if (text.text == widget.c) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Decrypt2(
                              texts: widget.texts,
                              proid: widget.proid,
                              c: widget.c,
                              d: widget.d,
                            ),
                          ),
                        );
                      }

                      text.text = "";
                    });
                  },
                  child: Container(
                    height: 50.0,
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Decrypt2 extends StatefulWidget {
  final String c, d;
  final List<Chats> texts;
  final String proid;

  Decrypt2({this.texts, this.proid, this.c, this.d});

  @override
  _CreateAccountState2 createState() => _CreateAccountState2();
}

class _CreateAccountState2 extends State<Decrypt2> {
  TextEditingController text = TextEditingController();
  ScrollController _myController = ScrollController();

  @override
  Widget build(BuildContext parentContext) {
    Timer(Duration(milliseconds: 0),
        () => _myController.jumpTo(_myController.position.maxScrollExtent));
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.d),
        ),
        body: ListView(
          controller: _myController,
          children: List.generate(
            widget.texts.length,
            (index) {
              return Container(
                padding: EdgeInsets.only(
                    top: 8,
                    bottom: 8,
                    left:
                        (widget.proid == widget.texts[index].senderId) ? 0 : 24,
                    right: (widget.proid == widget.texts[index].senderId)
                        ? 24
                        : 0),
                alignment: (widget.proid == widget.texts[index].senderId)
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: GestureDetector(
                  onDoubleTap: () {
                    return showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            title: Text(
                              "OPTIONS",
                              textAlign: TextAlign.center,
                            ),
                            children: <Widget>[
                              Center(
                                  child: Text(
                                      "(Go to the prev page to see the changes)\n")),
                              SimpleDialogOption(
                                  onPressed: () {
                                    if (currentUser.id ==
                                        widget.texts[index].senderId) {
                                      Navigator.pop(context);
                                      chatRef
                                          .document(
                                              widget.texts[index].senderId)
                                          .collection(
                                              widget.texts[index].recieverId)
                                          .document(widget.texts[index].mid)
                                          .get()
                                          .then((doc) {
                                        if (doc.exists) {
                                          doc.reference.delete();
                                        }
                                      });
                                      mref
                                          .document(
                                              widget.texts[index].senderId)
                                          .collection("messages")
                                          .document(widget.texts[index].mid)
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
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            "JustAnotherHand",
                                                        fontSize: 30.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white)),
                                                content: Text(
                                                    "However ${widget.texts[index].recieverName} can still see that message!!!",
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white)),
                                              ));
                                    } else {
                                      Navigator.pop(context);
                                      chatRef
                                          .document(
                                              widget.texts[index].recieverId)
                                          .collection(
                                              widget.texts[index].senderId)
                                          .document(widget.texts[index].mid)
                                          .get()
                                          .then((doc) {
                                        if (doc.exists) {
                                          doc.reference.delete();
                                        }
                                      });
                                      mref
                                          .document(
                                              widget.texts[index].recieverId)
                                          .collection("messages")
                                          .document(widget.texts[index].mid)
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
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            "JustAnotherHand",
                                                        fontSize: 30.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white)),
                                                content: Text(
                                                    "However ${widget.texts[index].senderName} can still see that message!!!",
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
                                        widget.texts[index].senderId) {
                                      Navigator.pop(context);
                                      chatRef
                                          .document(
                                              widget.texts[index].senderId)
                                          .collection(
                                              widget.texts[index].recieverId)
                                          .document(widget.texts[index].mid)
                                          .get()
                                          .then((doc) {
                                        if (doc.exists) {
                                          doc.reference.delete();
                                        }
                                      });
                                      chatRef
                                          .document(
                                              widget.texts[index].recieverId)
                                          .collection(
                                              widget.texts[index].senderId)
                                          .document(widget.texts[index].mid)
                                          .get()
                                          .then((doc) {
                                        if (doc.exists) {
                                          doc.reference.delete();
                                        }
                                      });
                                      mref
                                          .document(
                                              widget.texts[index].senderId)
                                          .collection("messages")
                                          .document(widget.texts[index].mid)
                                          .get()
                                          .then((doc) {
                                        if (doc.exists) {
                                          doc.reference.delete();
                                        }
                                      });
                                      mref
                                          .document(
                                              widget.texts[index].recieverId)
                                          .collection("messages")
                                          .document(widget.texts[index].mid)
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
                                                    textAlign: TextAlign.center,
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
                                                    textAlign: TextAlign.center,
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
                    margin: (widget.proid == widget.texts[index].senderId)
                        ? EdgeInsets.only(left: 30)
                        : EdgeInsets.only(right: 30),
                    padding: EdgeInsets.only(
                        top: 17, bottom: 17, left: 20, right: 20),
                    decoration: BoxDecoration(
                        borderRadius:
                            (widget.proid == widget.texts[index].senderId)
                                ? BorderRadius.only(
                                    topLeft: Radius.circular(23),
                                    topRight: Radius.circular(23),
                                    bottomLeft: Radius.circular(23))
                                : BorderRadius.only(
                                    topLeft: Radius.circular(23),
                                    topRight: Radius.circular(23),
                                    bottomRight: Radius.circular(23)),
                        gradient: LinearGradient(
                          colors: (widget.proid == widget.texts[index].senderId)
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
                            child: SelectableText(widget.texts[index].message,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: (widget.proid ==
                                            widget.texts[index].senderId)
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold))),
                        Padding(
                            padding: EdgeInsets.only(top: 12.0),
                            child: Text(
                              "${funny(widget.texts[index].timestamp.toDate().toString())}\n${funny1(widget.texts[index].timestamp.toDate().toString())}",
                              style: TextStyle(
                                  color: (widget.proid ==
                                          widget.texts[index].senderId)
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
        ));
  }
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
