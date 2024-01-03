class BaseModel<T> {
  int? statusCode;
  bool? success;
  String? message;
  T? body;

  BaseModel({
    this.statusCode,
    this.success,
    this.message,
    this.body,
  });

  Map<String, dynamic> toJson() {
    return {
      'status_code': statusCode,
      'success': success,
      'message': message,
      'body': body,
    };
  }

  factory BaseModel.fromJson(Map<String, dynamic> json,
      {T Function(Object? jsonT)? fromJsonT}) {
    return BaseModel(
      statusCode: json['status_code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      body: json['body'] == null ? null : fromJsonT?.call(json['body']),
      // ko biet json['body'] la model nao de map vao
      // tra json['body'] vao jsonT de xu ly, goi la callback
    );
  }

  factory BaseModel.binhPhuong(int a, {T Function(int? number)? callback}) {
    return BaseModel(
      body: callback?.call(a * a),
    );
  }

  factory BaseModel.name2(Map<String, dynamic> json,
      {T Function(Object? number)? callback}) {
    return BaseModel(
      body: json['status_code'] == null
          ? null
          : callback?.call(json['status_code']),
    );
  }

  @override
  String toString() =>
      "BaseModel(statusCode: $statusCode,success: $success,message: $message,body: $body)";

  @override
  int get hashCode => Object.hash(statusCode, success, message, body);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseModel &&
          runtimeType == other.runtimeType &&
          statusCode == other.statusCode &&
          success == other.success &&
          message == other.message &&
          body == other.body;
}
