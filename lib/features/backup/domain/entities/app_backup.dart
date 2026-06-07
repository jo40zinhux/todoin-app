/// Snapshot exportável de todos os dados locais do app.
class AppBackup {
  final int version;
  final String exportedAt;
  final List<Map<String, dynamic>> tasks;
  final int xp;
  final Map<String, dynamic> stats;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> reminders;

  const AppBackup({
    required this.version,
    required this.exportedAt,
    required this.tasks,
    required this.xp,
    required this.stats,
    required this.settings,
    required this.reminders,
  });

  Map<String, dynamic> toJson() => {
        'version': version,
        'exportedAt': exportedAt,
        'tasks': tasks,
        'xp': xp,
        'stats': stats,
        'settings': settings,
        'reminders': reminders,
      };

  factory AppBackup.fromJson(Map<String, dynamic> json) {
    return AppBackup(
      version: json['version'] as int? ?? 1,
      exportedAt: json['exportedAt'] as String? ?? '',
      tasks: (json['tasks'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      xp: json['xp'] as int? ?? 0,
      stats: Map<String, dynamic>.from(
        json['stats'] as Map? ?? {},
      ),
      settings: Map<String, dynamic>.from(
        json['settings'] as Map? ?? {},
      ),
      reminders: Map<String, dynamic>.from(
        json['reminders'] as Map? ?? {},
      ),
    );
  }
}
