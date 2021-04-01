import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jc_messenger/models/muser.dart';
import 'package:jc_messenger/pages/chat_box.dart';
import 'package:jc_messenger/pages/sign_in.dart';
import 'package:jc_messenger/widgets/progress.dart';

class Search extends StatefulWidget {
  final String id;
  Search({this.id});
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;
  Muser x;

  @override
  void initState() {
    super.initState();
    getdetails();
  }

  getdetails() async {
    DocumentSnapshot doc = await musersRef.document(widget.id).get();

    setState(() {
      x = Muser.fromDocument(doc);
    });
  }

  handleSearch(String query) {
    Future<QuerySnapshot> users = musersRef
        .where("displayName", isGreaterThanOrEqualTo: query)
        .getDocuments();

    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
        automaticallyImplyLeading: false,
        title: TextFormField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Search for a user...",
            filled: true,
            prefixIcon: Icon(
              Icons.account_box,
              size: 28.0,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: clearSearch,
            ),
          ),
          onFieldSubmitted: handleSearch,
        ));
  }

  Center buildNoContent() {
    return Center(child: Image.asset("images/7.png", fit: BoxFit.cover));
  }

  fun() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("THAT'S  YOUR  ACCOUNT !!!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "JustAnotherHand",
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              // content:  Text("",style:TextStyle(fontSize: 17, fontWeight: FontWeight.bold,color: Colors.white)),
            ));
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Muser> searchResults = [];
        snapshot.data.documents.forEach((doc) {
          Muser user = Muser.fromDocument(doc);
          searchResults.add(user);
        });
        return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/5.png"),
              ),
            ),
            child: ListView(
                children: List.generate(
              searchResults.length,
              (index) {
                return Container(
                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          if (searchResults[index].id != x.id)
                            showChat(context,
                                profileId: searchResults[index].id, uid: x.id);
                          else
                            fun();
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25.0,
                            backgroundColor: Colors.grey,
                            backgroundImage: CachedNetworkImageProvider(
                                searchResults[index].photoUrl),
                          ),
                          title: Text(
                            searchResults[index].displayName,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17),
                          ),
                          subtitle: Text(
                            searchResults[index].stat,
                            style: TextStyle(color: Colors.white38),
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
            )));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: Colors.blue[900],
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
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
