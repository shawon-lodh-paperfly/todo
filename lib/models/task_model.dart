class Task {
  int id;
  String title;
  String date;
  String priority;
  int status;

  Task(this.title, this.date, this.priority,
      this.status); // 0 - incomplete, 1 - complete
  Task.withId({this.id, this.title, this.date, this.priority, this.status});

  Map<String, dynamic> toMap() {
    final map = new Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['date'] = date;
    map['priority'] = priority;
    map['status'] = status.toString();
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    print(" from database: "
        '${map['id']},${map['title']},${map['date']},${map['priority']},${map['status']}');
    return Task.withId(
        id: map['id'],
        title: map['title'],
        date: map['date'],
        priority: map['priority'],
        status: map['status']);
  }
}
