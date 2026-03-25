class SubTask {
  final String title;
  final bool done;

  const SubTask({
    required this.title,
    this.done = false,
  });

  SubTask copyWith({
    String? title,
    bool? done,
  }) {
    return SubTask(
      title: title ?? this.title,
      done: done ?? this.done,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SubTask && other.title == title && other.done == done;
  }

  @override
  int get hashCode => title.hashCode ^ done.hashCode;
}
