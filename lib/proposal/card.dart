// import 'package:Solon/api/api_connect.dart';
import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:Solon/app_localizations.dart';
// import 'dart:convert'; // for jsonDecode

// import 'package:Solon/api/api_connect.dart';
import './page.dart';

class ProposalCard extends StatefulWidget {
  final int pid;
  final String title;
  final String description;
  final int uid;
  // final double daysLeft;
  // final DateTime endDate;
  // final DocumentSnapshot doc;
  // int numYea;
  // int numNay;
  // final String creator;

  ProposalCard({
    Key key,
    this.pid,
    this.title,
    this.description,
    this.uid,
    // this.daysLeft,
    // this.endDate,
    // this.numYea,
    // this.numNay,
    // this.doc,
    // this.creator,
  }) : super(key: key);

  @override
  _ProposalCardState createState() => _ProposalCardState();
}

class _ProposalCardState extends State<ProposalCard> {
  var voteChoiceVisibility = true;
  var collection;
  // final db = Firestore.instance;
  // String creatorName;

  void getCollection() {
    setState(() {
      // collection = db.collection('proposals');
    });
  }

  // Future<DocumentSnapshot> getCreator() async {
  //   return await db.collection('users').document(widget.creator).get();
  // }

  // Future<void> getVote(int pid, int uidUser) async {
  //   final responseMessage = await APIConnect.connectVotes(
  //     'GET',
  //     pid: pid,
  //     uidUser: uidUser,
  //   );
  //   print(responseMessage['message']);
  // }

  @override
  Widget build(BuildContext context) {
    getCollection();
    // print(getVote(widget.pid, widget.uid));
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProposalPage(
              pid: widget.pid,
              title: widget.title,
              description: widget.description,
              uidUser: widget.uid,
              // widget.daysLeft,
              // widget.endDate,
              // widget.numYea,
              // widget.numNay,
              // getCreator(),
            ),
          ),
        );
      },
      child: Center(
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.account_balance),
                title: Text(widget.title),
                subtitle: Text(widget.description),
              ),
              // Text('Voting on proposal ends on: ' +
              //     new DateFormat.yMMMMd("en_US")
              //         .add_jm()
              //         .format(widget.endDate)),
              // Text('Days left: ' + widget.daysLeft.toInt().toString()),
              // Visibility(
              //   visible: voteChoiceVisibility ? true : false,
              //   replacement: Text('You voted already!'),
              //   // make buttons use the appropriate styles for cards
              //   child: ButtonBar(
              //     alignment: MainAxisAlignment.center,
              //     children: <Widget>[
              //       FlatButton(
              //         child:
              //             Text(AppLocalizations.of(context).translate('yea')),
              //         color: pressAttention ? Colors.grey : Colors.blue,
              //         onPressed: () {
              //           // widget.numYea++;
              //           setState(() {
              //             voteChoiceVisibility = false;
              //           });
              //         },
              //       ),
              //       FlatButton(
              //         child:
              //             Text(AppLocalizations.of(context).translate('nay')),
              //         onPressed: () {
              //           // widget.numNay++;
              //           setState(() {
              //             voteChoiceVisibility = false;
              //           });
              //         },
              //       ),
              //       // FlatButton(
              //       //   child: Icon(Icons.delete),
              //       //   onPressed: () {
              //       //     APIConnect.deleteProposal(widget.pid);
              //       //     // collection.document(widget.doc.documentID).delete();
              //       //   },
              //       // ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
