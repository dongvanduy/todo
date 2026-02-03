class Task {
  int? id;
  String? title;
  String? note;
  String? project;
  int? isCompleted;
  int? isNote;
  String? date;
  String? startTime;
  String? endTime;
  int? color;
  int? remind;
  String? repeat;

  Task(
      {this.id,
      this.title,
      this.note,
      this.project,
      this.isCompleted,
      this.isNote,
      this.date,
      this.startTime,
      this.endTime,
      this.color,
      this.remind,
      this.repeat});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'project': project,
      'isCompleted': isCompleted,
      'isNote': isNote,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'color': color,
      'remind': remind,
      'repeat': repeat,
    };
  }

  Task.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    note = json['note'];
    project = json['project'];
    isCompleted = json['isCompleted'];
    isNote = json['isNote'];
    date = json['date'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    color = json['color'];
    remind = json['remind'];
    repeat = json['repeat'];
  }
}
