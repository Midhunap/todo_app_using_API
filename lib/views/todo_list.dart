import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_rest/views/add_todo.dart';
import 'package:http/http.dart' as http;
import 'package:todo_rest/views/edit_todo.dart';

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List items = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> addTask() async {
    final route = MaterialPageRoute(builder: (context) => const AddTodo());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    getData();
  }

  Future<void> editTask(Map item) async {
    final route = MaterialPageRoute(builder: (context) => AddTodo(todo: item));
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Todo List'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addTask,
        label: const Text('Add task'),
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: getData,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: const Center(
              child: Text('No todo items'),
            ),
            child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index] as Map;
                  final id = item['_id'] as String;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(
                        item['title'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white54,
                        ),
                      ),
                      subtitle: Text(item['description']),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'edit') {
                            editTask(item);
                          } else if (value == 'delete') {
                            deleteById(id);
                          }
                        },
                        position: PopupMenuPosition.under,
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ];
                        },
                      ),
                    ),
                  );
                }),
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> deleteById(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      final filteredItems = items
          .where((element) => element['_id'] != id)
          .toList(); //filtered the items without the deleted item.
      setState(() {
        items = filteredItems;
      });
    } else {
      //delete faild
    }
  }

  Future<void> getData() async {
    const url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }
}
