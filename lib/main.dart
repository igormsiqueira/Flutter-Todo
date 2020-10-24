

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:todo/database/todo_item.dart';

import 'database/db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DB.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterTodo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color.fromRGBO(58, 66, 86, 1.0),
        accentColor: Color.fromRGBO(209, 224, 224, 0.2),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ToDoItem> _todo = [];
  String _name;

  List<Widget> get _items => _todo.map((item) => format(item)).toList();

  Widget format(ToDoItem item) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Dismissible(
        onDismissed: (DismissDirection d) {
          DB.delete(ToDoItem.table, item);
          refresh();
        },
        key: Key(item.id.toString()),
        child: Container(
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Theme
                  .of(context)
                  .accentColor,
              shape: BoxShape.rectangle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0.0, 10))
              ]),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _creationDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Add Item"),
            content: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(labelText: "Item name"),
                    onChanged: (name) {
                      _name = name;
                    },
                  )
                ],
              ),
            ),
            actions: [
              FlatButton(
                onPressed: () => _save(),
                child: Text("Save"),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .primaryColor,
      body: Container(child: isListEmpty() ? getEmptyState() : getListView()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () => _creationDialog(context),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _save() async {
    Navigator.of(context).pop();
    if (_name.isEmpty) {
      return;
    }
    ToDoItem item = ToDoItem(name: _name);

    await DB.insert(ToDoItem.table, item);
    setState(() => _name = "");
    refresh();
  }

  void initState() {
    refresh();
    super.initState();
  }

  void refresh() async {
    List<Map<String, dynamic>> _results = await DB.query(ToDoItem.table);
    setState(() {
      _todo = _results.map((e) => ToDoItem.fromMap(e)).toList();
    });
  }

  bool isListEmpty() {
    return _todo.isEmpty;
  }

  getEmptyState() {
    return Center(
      child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SvgPicture.asset(
                    "assets/preguica_2.svg",
                    semanticsLabel: 'Empty Icon',
                    placeholderBuilder: (BuildContext context) =>
                        Container(
                            padding: const EdgeInsets.all(16.0),
                            child: const CircularProgressIndicator())),
              ),
              Text(
                "Breeeze nothing to do!",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 16),
              ),
            ],
          )
      ),
    );
  }

  getListView() {
    return ListView(
      children: <Widget>[
        Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 0, 10),
            child: Text(
              "To-do",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            )),
        ListView(
          children: _items,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
      ],
    );
  }
}
