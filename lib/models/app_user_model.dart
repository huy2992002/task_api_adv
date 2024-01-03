class AppUserModel {
  String? id;
  String? name;
  String? email;
  String? avatar;
  String? createdAt;
  String? updatedAt;
  int? v;

  AppUserModel({
    this.id,
    this.name,
    this.email,
    this.avatar,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: json['__v'] as int?,
    );
  }

  @override
  String toString() =>
      "CreatedBy(id: $id,name: $name,email: $email,avatar: $avatar,createdAt: $createdAt,updatedAt: $updatedAt,v: $v)";

  @override
  int get hashCode =>
      Object.hash(id, name, email, avatar, createdAt, updatedAt, v);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          avatar == other.avatar &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          v == other.v;
}
