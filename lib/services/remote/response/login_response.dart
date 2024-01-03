class LoginResponse {
  String? token;

  LoginResponse();

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      LoginResponse()..token = json['token'] as String?;

  Map<String, dynamic> toJson() {
    return {
      if (token != null) 'token': token,
    };
  }
}
