import 'package:flutter/material.dart';
import 'package:moor_db_viewer/moor_db_viewer.dart';
import 'package:provider/provider.dart';

import 'package:moor/moor.dart' as Moor;
import 'services/db.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (BuildContext context) => MyDB(),
          dispose: (context, db) => MyDB().close(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<MyDB>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("SQLite example"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => MoorDbViewer(database)));
              },
              child: Text("View DB"),
            ),
          ),
          TextFormField(
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: "Title"),
            controller: _titleController,
          ),
          TextFormField(
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: "Content"),
            controller: _contentController,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Create:
              ElevatedButton(
                onPressed: () {
                  database.todosDao.insertTodo(
                    TodosCompanion(
                        title: Moor.Value(_titleController.text),
                        content: Moor.Value(_contentController.text)),
                  );
                },
                child: Text("Add"),
              ),
            ],
          ),
          Expanded(
            // Read:
            child: StreamBuilder<List<Todo>>(
              stream: database.todosDao.watchAllTodoEntries(),
              builder: (BuildContext context, AsyncSnapshot<List<Todo>> snapshot) {
                final todos = snapshot.data;
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.data == null) {
                    return Text("You don't have any unfinished Todos");
                  }
                }

                return ListView.builder(
                  itemCount: todos!.length,
                  itemBuilder: (context, index) {
                    final items = todos[index];

                    return ListTile(
                      subtitle: ElevatedButton(
                        // Update:
                        onPressed: () {
                          database.todosDao.updateTodo(
                            Todo(
                                id: items.id,
                                title: (_titleController.text),
                                content: (_contentController.text),
                                completed: items.completed),
                          );
                        },
                        child: Text("Update"),
                      ),
                      leading: ElevatedButton(
                        // Delete:
                        onPressed: () {
                          database.todosDao.deleteTodo(items.id);
                        },
                        child: Text("Delete"),
                      ),
                      title: Text(items.title),
                      trailing: Text(items.content),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
