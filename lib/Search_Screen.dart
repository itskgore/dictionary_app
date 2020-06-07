import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:streamflutter/cofig.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool descTextShowFlag = false;

  TextEditingController _controller = TextEditingController();
  StreamController _streamController;
  Stream _stream;
  Timer search;
  _search() async {
    if (_controller.text == null || _controller.text.length == 0) {
      _streamController.add(null);
      return;
    } else {
      _streamController.add('waiting');
      final data = await http.get(url + _controller.text.trim(),
          headers: {'Authorization': 'Token ' + token});
      print(data.body);
      if (data.body.contains('[{"message":"No definition :("}]')) {
        _streamController.add('NoData');
        return;
      } else {
        _streamController.add(json.decode(data.body));
        return;
      }
    }
  }

  bool isExpanded = false;
  @override
  void initState() {
    _streamController = StreamController();
    _stream = _streamController.stream;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[800],
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.blueAccent),
          ),
          bottom: PreferredSize(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 12, bottom: 8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24)),
                      child: TextFormField(
                        autovalidate: true,
                        autocorrect: true,
                        textInputAction: TextInputAction.search,
                        onFieldSubmitted: (val) {
                          _search();
                        },
                        onChanged: (val) {
                          if (search?.isActive ?? false) search.cancel();
                          search = Timer(Duration(milliseconds: 1000), () {
                            _search();
                          });
                        },
                        controller: _controller,
                        decoration: InputDecoration(
                            hintText: 'Search for a word',
                            contentPadding: const EdgeInsets.only(left: 24.0),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _search();
                      })
                ],
              ),
              preferredSize: Size.fromHeight(48.0)),
        ),
        body: StreamBuilder(
          stream: _stream,
          builder: (ctx, snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: Text(
                  'Type a word to get its meaning 🤔',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              );
            }
            if (snapshot.data == 'waiting') {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.data == 'NoData') {
              return Center(
                child: Text(
                  'No Defination 😭',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data['definitions'].length,
                itemBuilder: (ctx, i) => ListBody(
                      children: [
                        Card(
                          color: Colors.grey[500],
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ExpansionTile(
                              onExpansionChanged: (bool expanding) =>
                                  setState(() => this.isExpanded = expanding),
                              // backgroundColor: Colors.grey,
                              leading: snapshot.data['definitions'][i]
                                          ['image_url'] ==
                                      null
                                  ? CircleAvatar(
                                      backgroundColor: Colors.black,
                                      child: Icon(Icons.chevron_right),
                                      maxRadius: 25,
                                    )
                                  : CircleAvatar(
                                      maxRadius: 25,
                                      backgroundImage: NetworkImage(snapshot
                                          .data['definitions'][i]['image_url']),
                                    ),
                              title: Text(
                                _controller.text.trim() +
                                    "  (" +
                                    snapshot.data['definitions'][i]['type'] +
                                    ")",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: isExpanded
                                      ? FontWeight.w400
                                      : FontWeight.w300,
                                  color:
                                      isExpanded ? Colors.white : Colors.black,
                                ),
                              ),
                              children: [
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Defination:',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      GestureDetector(
                                        onTap: () => {
                                          setState(() => descTextShowFlag =
                                              !descTextShowFlag)
                                        },
                                        child: snapshot
                                                .data['definitions'][i]
                                                    ['definition']
                                                .isNotEmpty
                                            ? AnimatedCrossFade(
                                                duration:
                                                    Duration(milliseconds: 400),
                                                crossFadeState: descTextShowFlag
                                                    ? CrossFadeState.showFirst
                                                    : CrossFadeState.showSecond,
                                                firstChild: Text(
                                                    snapshot.data['definitions']
                                                            [i]['definition']
                                                        .trimLeft(),
                                                    // textAlign: TextAlign.justify,
                                                    style: TextStyle(
                                                        height: 1.5,
                                                        fontSize: 17,
                                                        color: Colors.grey[900],
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                secondChild: Text(
                                                    snapshot.data['definitions']
                                                        [i]['definition'],
                                                    maxLines: 7,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        height: 1.5,
                                                        fontSize: 16,
                                                        color:
                                                            Colors.grey[1000],
                                                        fontWeight:
                                                            FontWeight.w400)),
                                              )
                                            : Container(),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Divider(
                                            endIndent: 100,
                                            color: Colors.white),
                                      ),
                                      snapshot.data['definitions'][i]['example']
                                                  .toString() !=
                                              'null'
                                          ? Text(
                                              'Example:',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            )
                                          : SizedBox(),
                                      snapshot.data['definitions'][i]['example']
                                                  .toString() !=
                                              'null'
                                          ? Text(
                                              snapshot.data['definitions'][i]
                                                      ['example']
                                                  .toString(),
                                              maxLines: 7,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  height: 1.5,
                                                  fontSize: 16,
                                                  color: Colors.grey[1000],
                                                  fontWeight: FontWeight.w400))
                                          : Container(),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ));
          },
        ));
  }
}
