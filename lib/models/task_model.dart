import 'package:task_api_adv/models/app_user_model.dart';

class TaskModel {
  String? id;
  String? name;
  String? description;
  String? startTime;
  String? endTime;
  String? status;
  dynamic createdBy;
  String? deletedAt;
  String? createdAt;
  String? updatedAt;
  int? v;

  bool isEditing = false;
  bool isConfirmDelete = false;
  bool isSelected = false;

  TaskModel({
    this.id,
    this.name,
    this.description,
    this.startTime,
    this.endTime,
    this.status,
    this.createdBy,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'created_by': createdBy,
      'deletedAt': deletedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      status: json['status'] as String?,
      createdBy: json['created_by'] == null
          ? null
          : json['created_by'] is Map<String, dynamic>
              ? AppUserModel.fromJson(
                  json['created_by'] as Map<String, dynamic>)
              : json['created_by'] as String,
      deletedAt: json['deletedAt'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: json['__v'] as int?,
    );
  }

  @override
  String toString() =>
      "Docs(id: $id,name: $name,description: $description,startTime: $startTime,endTime: $endTime,status: $status,createdBy: $createdBy,deletedAt: $deletedAt,createdAt: $createdAt,updatedAt: $updatedAt,v: $v)";

  @override
  int get hashCode => Object.hash(id, name, description, startTime, endTime,
      status, createdBy, deletedAt, createdAt, updatedAt, v);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          status == other.status &&
          createdBy == other.createdBy &&
          deletedAt == other.deletedAt &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          v == other.v;
}
