import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jc_messenger/models/muser.dart';
import 'package:jc_messenger/pages/sign_in.dart';
import 'package:jc_messenger/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String thisId = currentUser?.id;
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  Muser user;
  bool _displayNameValid = true;
  bool _bioValid = true;
  bool _unValid = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await musersRef.document(widget.profileId).get();
    user = Muser.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.stat;
    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Display Name",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _displayNameValid ? null : "Display Name too short",
          ),
        )
      ],
    );
  }

  Column buildDisplayName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Display Name",
              style: TextStyle(color: Colors.grey),
            )),
        Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 10.0),
            child: Text(
              "${user.displayName}",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ))
      ],
    );
  }

  Column buildstat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Status",
              style: TextStyle(color: Colors.grey),
            )),
        Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 10.0),
            child: Text(
              "${user.stat}",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ))
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              "Status",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Update Status",
            errorText: _bioValid ? null : "Status too long",
          ),
        )
      ],
    );
  }

  fun() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("PROFILE UPDATED!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "JustAnotherHand",
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              // content:  Text("You gotta follow atleast one user to see the timeline.Find some users to follow.Don't be a loner dude!!!!",style:TextStyle(fontSize: 17, fontWeight: FontWeight.bold,color: Colors.white)),
            ));
  }

  updateProfileData() {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_displayNameValid && _bioValid && _unValid) {
      musersRef.document(widget.profileId).updateData({
        "displayName": displayNameController.text,
        "stat": bioController.text,
      });
    }
    getUser();
    fun();
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignIn()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Profile",
          style: TextStyle(),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: logout,
            child: Icon(Icons.input),
          )
        ],
      ),
      body: isLoading
          ? Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 10.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ))
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          top: 16.0,
                          bottom: 8.0,
                        ),
                        child: GestureDetector(
                          child: CircleAvatar(
                            radius: 50.0,
                            backgroundColor: Colors.grey,
                            backgroundImage:
                                CachedNetworkImageProvider(user.photoUrl),
                          ),
                          onTap: () {},
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: (thisId == user.id)
                            ? Column(
                                children: <Widget>[
                                  buildDisplayNameField(),
                                  buildBioField(),
                                ],
                              )
                            : Column(
                                children: <Widget>[
                                  buildDisplayName(),
                                  buildstat(),
                                ],
                              ),
                      ),
                      (thisId == user.id)
                          ? RaisedButton(
                              color: Colors.white,
                              onPressed: updateProfileData,
                              child: Text(
                                "Update Profile",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            )
                          : Text(""),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
