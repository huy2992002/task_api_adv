class TaskResponse {
  String? name;
  String? description;
  String? startTime;
  String? endTime;
  String? status;
  String? deletedAt;
  String? id;
  String? createdAt;
  String? updatedAt;
  int? v;

  TaskResponse({
    this.name,
    this.description,
    this.startTime,
    this.endTime,
    this.status,
    this.deletedAt,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'deletedAt': deletedAt,
      '_id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    return TaskResponse(
      name: json['name'] as String?,
      description: json['description'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      status: json['status'] as String?,
      deletedAt: json['deletedAt'] as String?,
      id: json['_id'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: json['__v'] as int?,
    );
  }

  @override
  String toString() =>
      "TaskResponse(name: $name,description: $description,startTime: $startTime,endTime: $endTime,status: $status,deletedAt: $deletedAt,id: $id,createdAt: $createdAt,updatedAt: $updatedAt,v: $v)";

  @override
  int get hashCode => Object.hash(name, description, startTime, endTime, status,
      deletedAt, id, createdAt, updatedAt, v);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskResponse &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          status == other.status &&
          deletedAt == other.deletedAt &&
          id == other.id &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          v == other.v;
}
