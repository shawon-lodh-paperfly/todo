import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:todo_app/helpers/database_helper.dart';
import 'package:todo_app/models/task_model.dart';
import 'package:todo_app/screens/add_task_screen.dart';
import 'package:intl/intl.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({Key key}) : super(key: key);

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  Future<List<Task>> _taskList;
  final DateFormat _dateFormatter = DateFormat("MMM dd, yyyy");
  var _currentIndex = 0;
  var selectedDate = "";
  var _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedDate = _dateFormatter.format(DateTime.now());
    _updateTaskList();
  }

  void _updateTaskList() {
    setState(() {
      _taskList = null;
      _taskList = DatabaseHelper.instance.getTaskListByDate(selectedDate);
      print('updated list $_taskList');

      print("updateTask called");
    });
  }

  Widget _buildTask(Task task) {
    return Card(
      borderOnForeground: true,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(
          '${task.title}',
          style: TextStyle(
              fontSize: 18.0,
              decoration: task.status == 0
                  ? TextDecoration.none
                  : TextDecoration.lineThrough),
        ),
        subtitle: Text(
          '${task.date} * ${task.priority}',
          style: TextStyle(
              fontSize: 18.0,
              decoration: task.status == 0
                  ? TextDecoration.none
                  : TextDecoration.lineThrough),
        ),
        trailing: Checkbox(
            value: task.status == 1,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (value) {
              setState(() {
                task.status = value ? 1 : 0;
                DatabaseHelper.instance.updateTask(task);
                _updateTaskList();
              });
            }),
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) {
            return AddTaskScreen(task);
          },
        )).then((value) => _updateTaskList()),
      ),
    );
  }

  FutureOr onGoBack(dynamic value) {
    print("data 1");
    _updateTaskList();
    setState(() {});
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  _dateTimePicker() async {
    print("dateTime called");
    if (selectedDate.isNotEmpty) {
      _date = _dateFormatter.parse(selectedDate);
    } else {
      _date = DateTime.now();
    }
    final DateTime date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2010),
        lastDate: DateTime(2050));
    if (date != null) {
      setState(() {
        _date = date;
        selectedDate = _dateFormatter.format(_date);
        _updateTaskList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (context) => AddTaskScreen(null),
                )).then((value) {
              _updateTaskList();
            });
          },
        ),
        body: FutureBuilder(
          future: _taskList,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final int completedTaskCount = snapshot.data
                .where((Task task) => task.status == 1)
                .toList()
                .length;
            return ListView.builder(
                itemCount: 1 + snapshot.data.length,
                padding: EdgeInsets.symmetric(vertical: 35.0),
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Spacer(),
                              Icon(Icons.settings),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                "To Do's",
                                style: TextStyle(
                                    fontSize: 35,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Theme.of(context).primaryColor,
                                        style: BorderStyle.solid)),
                                child: TextButton(
                                  onPressed: () => _dateTimePicker(),
                                  child: Text(
                                    "$selectedDate",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "$completedTaskCount of ${snapshot.data.length}",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    );
                  }
                  return _buildTask(snapshot.data[index - 1]);
                });
          },
        ));
  }
}
