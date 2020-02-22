import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'package:Solon/models/proposal.dart';
import 'package:Solon/services/proposal_connect.dart';
import 'package:Solon/util/app_localizations.dart';
import 'package:Solon/widgets/screen_card.dart';
import 'package:Solon/widgets/bars/vote_bar.dart';
import 'package:Solon/screens/proposal/page.dart';

class ProposalCard extends StatefulWidget {
  final Proposal proposal;

  ProposalCard({
    Key key,
    this.proposal,
  }) : super(key: key);

  @override
  _ProposalCardState createState() => _ProposalCardState();
}

class _ProposalCardState extends State<ProposalCard> {
  bool _voted;
  Future<Map<String, dynamic>> _listFutureProposal;
  final GlobalKey _textKey = GlobalKey();
  double textWidth;

  Future<Map<String, dynamic>> getVote() async {
    final prefs = await SharedPreferences.getInstance();
    final userUid = json.decode(prefs.getString('userData'))['uid'];
    final responseMessage = await ProposalConnect.connectVotes(
      'GET',
      pid: widget.proposal.pid,
      uidUser: userUid,
    );
    return responseMessage;
  }

  @override
  void initState() {
    _listFutureProposal = getVote();
    // WidgetsBinding.instance.addPostFrameCallback((_) => getSize());
    super.initState();
  }

  getSize() {
    RenderBox _textBox = _textKey.currentContext.findRenderObject();
    textWidth = _textBox.size.width;
    print(textWidth);
  }

  @override
  Widget build(BuildContext context) {
    Function function = () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProposalPage(
            proposal: widget.proposal,
          ),
        ),
      );
    };
    ListTile tile = ListTile(
      contentPadding: EdgeInsets.only(
        top: 10,
        bottom: 10,
        right: 15,
        left: 15,
      ),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final String proposalTitle = widget.proposal.title;
            final int proposalTitleLength = proposalTitle.length;
            TextStyle textStyle = TextStyle(
              fontFamily: 'Raleway',
              fontWeight: FontWeight.bold,
              fontSize: 22,
            );
            final span = TextSpan(
              text: widget.proposal.title,
              style: textStyle,
            );
            final tp = TextPainter(
                text: span,
                textDirection: TextDirection
                    .ltr); // TODO: watch out for locale text direction
            tp.layout(maxWidth: constraints.maxWidth);
            final tpLineMetrics = tp.computeLineMetrics();
            print(tpLineMetrics[tpLineMetrics.length - 1].lineNumber);

            // TODO: This doesn't handle right-to-left text yet.
            // select everything
            TextSelection selection =
                TextSelection(baseOffset: 0, extentOffset: span.text.length);

            // get a list of TextBoxes (Rects)
            List<TextBox> boxes = tp.getBoxesForSelection(selection);

            // Loop through each text box
            List<String> lineTexts = [];
            int start = 0;
            int end;
            int index = -1;
            for (TextBox box in boxes) {
              index += 1;

              // Uncomment this if you want to only get the whole line of text
              // (sometimes a single line may have multiple TextBoxes)
              if (box.left != 0.0) continue;

              if (index == 0) continue;
              // Go one logical pixel within the box and get the position
              // of the character in the string.
              end = tp
                  .getPositionForOffset(Offset(box.left + 1, box.top + 1))
                  .offset;
              // add the substring to the list of lines
              final line = proposalTitle.substring(start, end);
              lineTexts.add(line);
              start = end;
            }
            // get the last substring
            final extra = proposalTitle.substring(start);
            lineTexts.add(extra);
            print(lineTexts);

            int totalTextWidth =
                (tpLineMetrics[0].width * (tpLineMetrics.length - 1) +
                        tpLineMetrics[tpLineMetrics.length - 1].width)
                    .ceil();
            double avgCharPixelWidth = (totalTextWidth / proposalTitleLength);
            int lastLineCharDiff = lineTexts[lineTexts.length - 1].length;
            print(avgCharPixelWidth);
            String titleText;

            if (tpLineMetrics.length == 1) {
              // The text only has 1 line.
              // TODO: display the one-line text
              // return Text(
              //   widget.proposal.title,
              //   style: textStyle,
              // );
              titleText = proposalTitle; 
            } else if (lineTexts[lineTexts.length - 1].length +
                    (3 * avgCharPixelWidth) >
                constraints.maxWidth) {
              // (tpLineMetrics[tpLineMetrics.length - 1].width /
              //         avgCharPixelWidth)
              //     .ceil();

              titleText = proposalTitle.substring(
                      0, proposalTitleLength - lastLineCharDiff - 3) +
                  '...';
              print(titleText);
              
            } else if (lineTexts[lineTexts.length - 1].length +
                    (3 * avgCharPixelWidth) <=
                constraints.maxWidth) {
              titleText =
                  proposalTitle.substring(0, proposalTitleLength) + '...';
            }
            return Text(
                titleText,
                style: textStyle,
                // maxLines: tpLineMetrics.length - 1,
              );
          },
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "${AppLocalizations.of(context).translate("numDaysUntilVotingEnds")} ${widget.proposal.date.difference(DateTime.now()).inDays.toString()}",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            "${widget.proposal.yesVotes + widget.proposal.noVotes} ${AppLocalizations.of(context).translate("votes")}",
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: _listFutureProposal,
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.data == null) {
                return Center();
              } else {
                _voted = (snapshot.data['message'] == 'Error') ? false : true;
                if (_voted) {
                  return VoteBar(
                    numYes: widget.proposal.yesVotes,
                    numNo: widget.proposal.noVotes,
                  );
                } else {
                  return Center();
                }
              }
            },
          ),
        ],
      ),
    );
    return ScreenCard(tile: tile, function: function);
  }
}
