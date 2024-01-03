import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pretty_http_logger/pretty_http_logger.dart';
import 'package:task_api_adv/constants/app_constant.dart';
import 'package:task_api_adv/models/base_model.dart';
import 'package:task_api_adv/services/local/shared_prefs.dart';
import 'package:task_api_adv/services/remote/body/change_password_body.dart';
import 'package:task_api_adv/services/remote/body/login_body.dart';
import 'package:task_api_adv/services/remote/body/new_password_body.dart';
import 'package:task_api_adv/services/remote/body/register_body.dart';
import 'package:task_api_adv/services/remote/response/login_response.dart';
import 'package:task_api_adv/services/remote/code_error.dart';

abstract class ImplAuthServices {
  Future<dynamic> sendOtp(String email);
  Future<dynamic> register(RegisterBody body);
  Future<dynamic> login(LoginBody body);
  Future<http.Response> postForgotPassword(NewPasswordBody body);
  Future<http.Response> changePassword(ChangePasswordBody body);
}

class AuthServices implements ImplAuthServices {
  static final httpLog = HttpWithMiddleware.build(middlewares: [
    HttpLogger(logLevel: LogLevel.BODY),
  ]);

  @override
  Future<dynamic> sendOtp(String email) async {
    const url = AppConstant.endPointOtp;

    try {
      http.Response response = await httpLog.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${null}',
        },
        body: jsonEncode({'email': email}),
      );

      final data = BaseModel<dynamic>.fromJson(jsonDecode(response.body));

      if (data.success == false) {
        throw Exception(data.message.toLang);
      }
    } on http.ClientException catch (_) {
      throw Exception();
    }
  }

  @override
  Future<dynamic> register(RegisterBody body) async {
    const url = AppConstant.endPointAuthRegister;

    try {
      http.Response response = await httpLog.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${null}',
        },
        body: jsonEncode(body.toJson()),
      );

      final data = BaseModel<dynamic>.fromJson(jsonDecode(response.body));

      if (data.success == false) {
        throw Exception(data.message.toLang);
      }
    } on http.ClientException catch (_) {
      throw Exception();
    }
  }

  @override
  Future<dynamic> login(LoginBody body) async {
    const url = AppConstant.endPointLogin;

    try {
      http.Response response = await httpLog.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${null}',
        },
        body: jsonEncode(body.toJson()),
      );

      final data = BaseModel<LoginResponse>.fromJson(
        jsonDecode(response.body),
        fromJsonT: (jsonT) =>
            LoginResponse.fromJson(jsonT as Map<String, dynamic>),
      );

      if (data.success == true) {
        SharedPrefs.token = data.body?.token;
      } else {
        throw Exception(data.message.toLang);
      }
    } on http.ClientException catch (_) {
      throw Exception();
    }
  }

  @override
  Future<http.Response> postForgotPassword(NewPasswordBody body) async {
    const url = AppConstant.endPointForgotPassword;

    http.Response response = await httpLog.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${null}',
      },
      body: jsonEncode(body.toJson()),
    );
    return response;
  }

  @override
  Future<http.Response> changePassword(ChangePasswordBody body) async {
    const url = AppConstant.endPointChangePassword;

    http.Response response = await httpLog.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${SharedPrefs.token}',
      },
      body: jsonEncode(body.toJson()),
    );
    return response;
  }
}
