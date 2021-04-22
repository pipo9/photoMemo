import "package:flutter/material.dart";
import 'package:photomemo/models/photomemo.dart';
import 'package:photomemo/screens/memo_details.dart';

class MemoItem extends StatelessWidget {
  MemoItem(
      {@required this.width,
      @required this.memoItem,
     });

  final double width;
  final PhotoMemo memoItem;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, MemoDetails.routeName,
            arguments: {"memoItem": memoItem});
      },
      child: Column(
        children: [
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.only(left: width * 0.05),
            child: Row(
              children: [
                if (memoItem.photoURL.isNotEmpty)
                  Image.network(
                    memoItem.photoURL,
                    width: width * 0.3,
                  ),
                SizedBox(width: width * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memoItem.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      width: width * 0.5,
                      child: Text(memoItem.memo),
                    ),
                    SizedBox(height: 10),
                    memoItem.comments.length >0
                        ? Container(
                      width: width * 0.5,
                      child: Text(
                        "View comments...",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    )
                        : SizedBox(),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Divider(
            color: Colors.white,
            height: 1,
          ),
        ],
      ),
    );
  }
}
