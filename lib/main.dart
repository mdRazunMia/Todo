import 'package:flutter/material.dart';
import './databaseHelper.dart';
import './models/todo.dart';
import './screens/todo_detail.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyTodoList(),
    );
  }
}

class MyTodoList extends StatefulWidget {
  MyTodoList({Key key}) : super(key: key);

  @override
  _MyTodoListState createState() => _MyTodoListState();
}

class _MyTodoListState extends State<MyTodoList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Todo> todoList;
  int count = 0;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String get todo => null;
  String get title => null;
  // String get title => null;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) {
    debugPrint("payload : $payload");
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text('Notification'),
        content: new Text('$payload'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (todoList == null) {
      todoList = List<Todo>();
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('My todo App'),
      ),
      body: getTodoListView(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Add Todo',
        onPressed: () {
          navigateToDetail(Todo(' ', ' '), 'Add Todo');
        },
      ),
    );
  }

  ListView getTodoListView() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber,
              child: Text(
                getFirstLetter(this.todoList[position].title),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              this.todoList[position].title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(this.todoList[position].date),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onTap: () {
                    _delete(context, todoList[position]);
                  },
                ),
              ],
            ),
            onTap: () {
              navigateToDetail(this.todoList[position], 'Edit Todo');
            },
          ),
        );
      },
    );
  }

  void navigateToDetail(Todo todo, String title) async {
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return TodoDetail(this.title, todo);
        },
      ),
    );
    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Todo>> todoListFuture = databaseHelper.getTodoList();
      todoListFuture.then((todoList) {
        setState(() {
          this.todoList = todoList;
          this.count = todoList.length;
        });
      });
    });
  }

  void _delete(BuildContext context, Todo todo) async {
    int result = await databaseHelper.deleteTodo(todo.id);
    if (result != 0) {
      _showSnakeBar(context, 'Todo Deleted Successfully');
      updateListView();
    }
  }

  void _showSnakeBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  getFirstLetter(String title) {
    return title.substring(0, 2);
  }

  showNotification() async {
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0, 'New Tutorial', 'Local Notification', platform,
        payload: 'AndroidCoding.in');
  }
}
