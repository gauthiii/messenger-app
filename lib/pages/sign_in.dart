import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jc_messenger/models/fid.dart';
import 'package:jc_messenger/models/muser.dart';
import 'package:jc_messenger/pages/create_pwd.dart';
import 'package:jc_messenger/pages/profile.dart';
import 'package:jc_messenger/pages/search.dart';
import 'package:jc_messenger/widgets/progress.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'inbox.dart';
import 'inbox2.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final musersRef = Firestore.instance.collection('Musers');
final chatRef = Firestore.instance.collection('Chatbox');
final idRef = Firestore.instance.collection('Convos');
final mref = Firestore.instance.collection('Messages');
final DateTime timestamp = DateTime.now();
Muser currentUser;
Fid fid;

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isLoading = false;
  bool isAuth = false;
  String name, email, pid;

  PageController pageController;
  int pageIndex = 0;

  final FirebaseMessaging _messaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    pageController = PageController();

    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        isLoading = true;
      });
      handleSignIn(account);
      _messaging.getToken().then((token) {
        print("Token: " + token);
      });
    }, onError: (err) {
      print('Error signing in: $err');
    });
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      setState(() {
        isLoading = true;
      });
      handleSignIn(account);
      _messaging.getToken().then((token) {
        print("Token: " + token);
      });
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) async {
    setState(() {
      isLoading = true;
    });
    if (account != null) {
      print('User signed in!: $account');
      await createUserInFirestore();

      setState(() {
        isAuth = true;
        isLoading = false;
        name = account.displayName;
        email = account.email;
        pid = account.photoUrl;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  getids() async {
    DocumentSnapshot doc = await idRef.document(currentUser?.id).get();

    if (!doc.exists) {
      idRef.document(currentUser.id).setData({
        "Ids": [],
      });
    }

    setState(() {
      fid = Fid.fromDocument(doc);
    });
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await musersRef.document(user.id).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      final pwd = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreatePwd()));

      // 3) get username from create account, use it to make new user document in users collection
      musersRef.document(user.id).setData({
        "id": user.id,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "stat": "(No Status)",
        "pwd": pwd,
        "timestamp": timestamp,
        "Ids": [],
      });

      doc = await musersRef.document(user.id).get();
    }

    currentUser = Muser.fromDocument(doc);
    print(currentUser.displayName);
  }

  login() {
    setState(() {
      isLoading = true;
    });
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 200), curve: Curves.bounceOut);
  }

  Widget buildAuthScreen() {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: PageView(
        children: <Widget>[
          Inbox(user: currentUser, x: currentUser.ids),
          Search(id: currentUser?.id),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: Colors.white,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.mail),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
            ),
          ]),
    );
  }

  Scaffold buildUnAuthScreen() {
    AssetImage img = AssetImage('images/5.png');
    Image im1 = Image(
      image: img,
      width: 512.0,
      height: 512.0,
    );

    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "JC",
              style: TextStyle(
                  fontFamily: "Knewave",
                  color: Colors.black,
                  fontSize: 300.0,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "MESSENGER\n",
              style: TextStyle(
                  fontFamily: "Knewave",
                  color: Colors.black,
                  fontSize: 65.0,
                  fontWeight: FontWeight.bold),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 40.0,
              child: RaisedButton(
                onPressed: login,
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                color: Colors.black,
                child: Text(
                  "Sign in with Google",
                  style: TextStyle(
                      fontFamily: "RussoOne",
                      color: Colors.white,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            (isLoading == true) ? circularProgress() : Text("")
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
