import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Parallel Penguins Observability - 🐧🐧🐧🐧🐧';
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        title: title,
        channel:
            WebSocketChannel.connect(Uri.parse('ws://alfapt-db01.fanniemae.com:20079/ws/notifications')),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final WebSocketChannel channel;

  MyHomePage({Key key, @required this.title, @required this.channel})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller = TextEditingController();
  var concatenate = StringBuffer();
  List<Widget> messageList = <Widget>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        // child: Column(
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: [
        //     Form(
        //       child: TextFormField(
        //         controller: _controller,
        //         decoration: InputDecoration(
        //           hintText: 'Enter the process id',
        //           suffixIcon: IconButton(
        //             onPressed: () {
        //               _sendMessage();
        //             },
        //             icon: Icon(Icons.search),
        //           ),
        //         ),
        //       ),
        //     ),
        //     //Padding(padding: EdgeInsets.only(right: 50)),
        //   ],
        // ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Form(
            //   child: TextFormField(
            //     controller: _controller,
            //     decoration: InputDecoration(
            //         labelText: 'Search for process id',
            //         suffixIcon: IconButton(
            //           onPressed: _sendMessage,
            //           icon: Icon(Icons.search),
            //         )),
            //   ),
            // ),
            FloatingActionButton(
              onPressed: _sendMessage,
              tooltip: 'Search',
              child: Icon(Icons.search),
            ),
            StreamBuilder(
              stream: widget.channel.stream,
              builder: (context, snapshot) {
                List<Widget> children;
                if (snapshot.hasError) {
                  children = <Widget>[
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child:
                          Text('Error receiving messages: ${snapshot.error}'),
                    )
                  ];
                } else {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      children = <Widget>[
                        Icon(
                          Icons.info,
                          color: Colors.blue,
                          size: 60,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                              'Connection state is not valid, please refresh the page.'),
                        )
                      ];
                      break;
                    case ConnectionState.waiting:
                      children = <Widget>[
                        SizedBox(
                          child: const CircularProgressIndicator(),
                          width: 60,
                          height: 60,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text('Waiting for messages...'),
                        )
                      ];
                      break;
                    case ConnectionState.active:
                      var message = Message.fromJson(snapshot.data);
                      children = <Widget>[
                        // Icon(
                        //   Icons.check_circle_outline,
                        //   color: Colors.green,
                        //   size: 60,
                        // ),
                        Padding(
                            padding: const EdgeInsets.only(top: 16),
                            //child: Text('${snapshot.data}'),
                            child: MessageList(messages: <Message>[message])),
                        // child: Card(
                        //   child: Column(
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: <Widget>[
                        //       const ListTile(
                        //         leading: Icon(Icons.assignment_turned_in),
                        //         title: Text('test'),
                        //         subtitle: subText,
                        //       )
                        //     ],
                        //   ),
                        // ),
                        //)
                      ];
                      messageList.addAll(children);
                      break;
                    case ConnectionState.done:
                      children = <Widget>[
                        Icon(
                          Icons.info,
                          color: Colors.blue,
                          size: 60,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text('\$${snapshot.data} (closed)'),
                        )
                      ];
                      break;
                  }
                }
                // return Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 24.0),
                //   child: Text(concatenate.toString()),
                // );
                //messageList.addAll(children);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: messageList.length == 0 ? children : messageList,
                );
              },
            )
          ],
        ),
        //),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: _sendMessage,
        //   tooltip: 'Search',
        //   child: Icon(Icons.search),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _sendMessage() {
    // if (_controller.text.isNotEmpty) {
    //   AlertDialog(
    //     content: Text(_controller.text),
    //   );
    //   widget.channel.sink.add(_controller.text);
    // }
    widget.channel.sink.add(
         '{type: "NOTIFICATIONS_REQUEST", data: {userName: "g3ujna", fetchCount: 10, refreshRate: 2000, order: "desc"}}');
    //widget.channel.sink.add(
    //    '{"type": "NOTIFICATIONS_RESPONSE","data": [{"id": 12,"userName": "g3ujna","notificationType": "INSERT", "productName": "SFWL","subProductName": "RPL-S","message": "Sample message","status": "RUNNING","insertedDate": "","updatedDate": ""}]}');
  }

  // Widget parseJson(String jsonString) {
  //   final messageGot = Message.fromJson(json.decode(jsonString));
  //   final messageString =
  //       'Status of ${messageGot.entityType}, ${messageGot.eventType} is ${messageGot.jobStatus}';
  //   return Card(
  //       child: Column(
  //         mainAxisAlignment: MainAxisSize.min,
  //         children: <Widget>[
  //           const ListTile(
  //             leading: Icon(Icons.assignment_turned_in),
  //             title: Text(
  //                 'Status of ${messageGot.entityType}, ${messageGot.eventType} is ${messageGot.jobStatus}'),
  //             subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
  //           ),
  //         ],
  //       ),
  //       text: 'Staus of ' +
  //           messageGot.entityType +
  //           " and " +
  //           messageGot.eventType +
  //           " is " +
  //           messageGot.jobStatus);
  // }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }
}

class MessageList extends StatelessWidget {
  final List<Message> messages;

  MessageList({Key key, this.messages}) : super(key: key);

  Widget build(BuildContext context) {
    Widget card;
    switch (messages[0].messageData[0].status) {
      case "COMPLETE":
        card = Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: Text(messages[0].messageData[0].status),
                subtitle: Text('Product: ' +
                    messages[0].messageData[0].productName +
                    '\nEvent Type:' +
                    messages[0].messageData[0].subProductName +
                    '\nMessage: ' +
                    messages[0].messageData[0].message),
              ),
            ],
          ),
        );
        break;
      case "RUNNING":
        card = Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.check_circle, color: Colors.yellow),
                title: Text(messages[0].messageData[0].status),
                subtitle: Text('\n\nProduct: ' +
                    messages[0].messageData[0].productName +
                    '\nEvent Type:' +
                    messages[0].messageData[0].subProductName +
                    '\nMessage: ' +
                    messages[0].messageData[0].message),
              ),
            ],
          ),
        );
        break;
      case "FAILED":
        card = Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.warning, color: Colors.red),
                title: Text(messages[0].messageData[0].status),
                subtitle: Text('\n\nProduct: ' +
                    messages[0].messageData[0].productName +
                    '\nEvent Type:' +
                    messages[0].messageData[0].subProductName +
                    '\nMessage: ' +
                    messages[0].messageData[0].message),
              ),
            ],
          ),
        );
        break;
      default:
    }
    return Column(
      children: <Widget>[
        Container(
          // constraints: BoxConstraints.expand(
          //     //height:
          //     //    Theme.of(context).textTheme.display1.fontSize * 1.1 + 200.0,
          //     ),
          color: Colors.white10,
          alignment: Alignment.center,
          child: card,
          // child: Card(
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     children: <Widget>[
          //       ListTile(
          //         leading: Icon(Icons.check),
          //         title: Text(messages[0].jobStatus),
          //         subtitle: Text('\n\nEntity Type: ' +
          //             messages[0].entityType +
          //             '\n\nEvent Type:' +
          //             messages[0].entityType),
          //       ),
          //     ],
          //   ),
          // )
        ),
      ],
    );
  }
}

class Message {
  final String type;
  final List<MessageData> messageData;

  Message({this.type, this.messageData});

  factory Message.fromJson(String jsonStr) {
    Map<String, dynamic> json = jsonDecode(jsonStr);
    var list = json['data'];
    print(list.runtimeType);
    var dynamicList = list.map((i) => MessageData.fromJson(i)).toList();
    var messageData = List<MessageData>.from(dynamicList);
    print(messageData.runtimeType);
    return Message(type: json['type'] as String, messageData: messageData);
  }
}

class MessageData {
  final int id;
  final String userName;
  final String notificationType;
  final String productName;
  final String subProductName;
  final String message;
  final String status;
  final String insertedDate;
  final String updatedDate;

  MessageData(
      {this.id,
      this.userName,
      this.notificationType,
      this.productName,
      this.subProductName,
      this.message,
      this.status,
      this.insertedDate,
      this.updatedDate});

  factory MessageData.fromJson(Map<String, dynamic> json) {
    //Map<String, dynamic> json = jsonDecode(jsonStr);
    print(json.runtimeType);
    return MessageData(
        id: json['id'] as int,
        userName: json['userName'] as String,
        notificationType: json['notificationType'] as String,
        productName: json['productName'] as String,
        subProductName: json['subProductName'] as String,
        message: json['message'] as String,
        status: json['status'] as String,
        insertedDate: json['insertedDate'] as String,
        updatedDate: json['updatedDate'] as String);
  }
}
