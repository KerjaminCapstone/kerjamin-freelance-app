class ArrangeDetail {
  ArrangeDetail(
    this.harga,
    this.tasks,
  );

  int? harga;
  List<Task> tasks;
}

class Task {
  Task(
    this.IdTask,
    this.TaskDesc,
  );

  String? IdTask;
  String? TaskDesc;
}
