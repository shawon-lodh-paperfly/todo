import 'package:flutter/material.dart';
import 'package:todo_app/helpers/database_helper.dart';
import 'package:todo_app/models/task_model.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  Task task;

  AddTaskScreen(this.task);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formkey = GlobalKey<FormState>();
  String _title = "";
  String taskButton = "Submit";
  DateTime _date = DateTime.now();

  TextEditingController _dateController = TextEditingController();
  final DateFormat _dateFormatter = DateFormat("MMM dd, yyyy");
  String _formatedDate = "";
  static const List<String> _priorities = ['Low', 'Medium', 'High'];
  String _priority = _priorities.first;

  _dateTimePicker() async {
    final DateTime date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2010),
        lastDate: DateTime(2050));
    if (date != null && date != _date) {
      setState(() {
        _date = date;
        _dateController.text = _dateFormatter.format(_date);
      });
    }
  }

  _submit() async {
    if (_formkey.currentState.validate()) {
      _formkey.currentState.save();
      print('$_title,$_date,$_priority,${DatabaseHelper.instance}');

      Task task = Task(_title, _dateFormatter.format(_date), _priority, 0);
      if (widget.task == null) {
        int data = await DatabaseHelper.instance.insertTask(task);
        print("insertion  $data");
      } else {
        task.id = widget.task.id;
        int data = await DatabaseHelper.instance.updateTask(task);
        print("updation  $data");
      }

      Navigator.pop(context, true);
    }
  }

  @override
  void initState() {
    super.initState();
    _formatedDate = _dateFormatter.format(DateTime.now());
    if (widget.task != null) {
      _title = widget.task.title;
      _formatedDate = widget.task.date;
      _dateController.text = _dateFormatter.format(_date);
      _priority = widget.task.priority;
      _title = widget.task.title;
      taskButton = "Update";
    } else {
      _dateController.text = _dateFormatter.format(_date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, true);
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 80, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Task",
                    style: TextStyle(
                        fontSize: 35,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: TextFormField(
                              style: TextStyle(fontSize: 18.0),
                              decoration: InputDecoration(
                                  labelText: "title",
                                  labelStyle: TextStyle(fontSize: 18.0),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0))),
                              validator: (input) {
                                return input.trim().isEmpty
                                    ? 'Please enter task title'
                                    : null;
                              },
                              onSaved: (input) {
                                _title = input;
                              },
                              initialValue: _title,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              style: TextStyle(fontSize: 18.0),
                              onTap: _dateTimePicker,
                              decoration: InputDecoration(
                                  labelText: "date",
                                  labelStyle: TextStyle(fontSize: 18.0),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: DropdownButtonFormField(
                              isDense: true,
                              icon: Icon(Icons.arrow_drop_down_circle_rounded),
                              iconEnabledColor: Theme.of(context).primaryColor,
                              items: _priorities
                                  .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.black),
                                      )))
                                  .toList(),
                              style: TextStyle(fontSize: 18.0),
                              decoration: InputDecoration(
                                  labelText: "priority",
                                  labelStyle: TextStyle(fontSize: 18.0),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0))),
                              validator: (input) {
                                return _priority == null
                                    ? 'Please Select Priority'
                                    : null;
                              },
                              onChanged: (String value) {
                                setState(() {
                                  this._priority = value;
                                });
                              },
                              value: _priority,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(20),
                            height: 60,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(20)),
                            child: TextButton(
                              child: Text(
                                taskButton,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 26),
                              ),
                              onPressed: _submit,
                            ),
                          )
                        ],
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
      // ignore: missing_return
    );
  }
}
