enum SyncStatus { pending, syncing, confirmed, failed }

class KanbanCardModel {
  final String id;
  String title;
  String description;
  String columnId;
  int priority; // 0 = low, 1 = medium, 2 = high
  String? assignee;
  DateTime createdAt;
  DateTime updatedAt;
  List<String> tags;

  SyncStatus syncStatus;

  KanbanCardModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.columnId,
    this.priority = 0,
    this.assignee,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    this.syncStatus = SyncStatus.confirmed,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       tags = tags ?? [];

  /// Cards vindos da API são, por padrão, [SyncStatus.confirmed],

  factory KanbanCardModel.fromJson(Map<String, dynamic> json) {
    return KanbanCardModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      columnId: json['columnId'] ?? 'backlog',
      priority: json['priority'] ?? 0,
      assignee: json['assignee'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      syncStatus: SyncStatus.confirmed,
    );
  }

  /// IMPORTANTE: [syncStatus] NÃO entra no toJson — é estado de UI.
  /// O backend não precisa saber dele.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'columnId': columnId,
      'priority': priority,
      'assignee': assignee,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
    };
  }

  KanbanCardModel copyWith({
    String? title,
    String? description,
    String? columnId,
    int? priority,
    String? assignee,
    List<String>? tags,
    SyncStatus? syncStatus,
  }) {
    return KanbanCardModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      columnId: columnId ?? this.columnId,
      priority: priority ?? this.priority,
      assignee: assignee ?? this.assignee,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      tags: tags ?? this.tags,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

class KanbanColumnModel {
  final String id;
  final String title;

  const KanbanColumnModel({required this.id, required this.title});
}
