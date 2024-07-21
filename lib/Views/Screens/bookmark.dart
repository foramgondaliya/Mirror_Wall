import 'package:flutter/material.dart';
import 'package:mirror_wall/Modal/bookmark.dart';
import 'package:mirror_wall/Provider/bookmark_Provider.dart';
import 'package:provider/provider.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "All Bookmarks",
        ),
      ),
      body: Bookmark.urlData.isEmpty
          ? Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.no_sim,
                    size: 50,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "No Bookmark",
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  )
                ],
              ),
            )
          : Consumer<DeleteProvider>(
              builder:
                  (BuildContext context, DeleteProvider value, Widget? child) {
                return ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: Bookmark.urlData.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 3,
                      child: Container(
                        height: 90,
                        decoration:
                            BoxDecoration(color: Colors.grey.withOpacity(0.2)),
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed('mark',
                                      arguments:
                                          Bookmark.urlData[index].toString());
                                },
                                child: Text(
                                  "${Bookmark.urlData[index].toString()}",
                                  style: TextStyle(fontSize: 20),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                value.delete(index);
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
