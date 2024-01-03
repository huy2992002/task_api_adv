import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pretty_http_logger/pretty_http_logger.dart';
import 'package:task_api_adv/constants/app_constant.dart';
import 'package:task_api_adv/models/base_model.dart';
import 'package:task_api_adv/models/paging_model.dart';
import 'package:task_api_adv/models/task_model.dart';
import 'package:task_api_adv/services/local/shared_prefs.dart';
import 'package:task_api_adv/services/remote/body/delete_task_body.dart';
import 'package:task_api_adv/services/remote/body/task_body.dart';
import 'package:task_api_adv/services/remote/code_error.dart';

abstract class ImplTaskServices {
  Future<List<TaskModel>?> getListTask({Map<String, dynamic>? queryParams});
  Future<http.Response> createTask(TaskBody body);
  Future<http.Response> updateTask(TaskBody body);
  Future<http.Response> deleteTask(String id);
  Future<http.Response> deleteMultipleTask(DeleteTaskBody body);
  Future<http.Response> restoreMultipleTask(DeleteTaskBody body);
}

class TaskServices implements ImplTaskServices {
  static final httpLog = HttpWithMiddleware.build(middlewares: [
    HttpLogger(logLevel: LogLevel.BODY),
  ]);

  @override
  Future<List<TaskModel>?> getListTask(
      {Map<String, dynamic>? queryParams}) async {
    String? token = SharedPrefs.token;

    const url = AppConstant.endPointGetListTask;

    String query = queryParams?.entries
            .map((e) => '${e.key}=${e.value}')
            .toList()
            .join('&') ??
        '';
    final requestUrl = query.isEmpty ? url : '$url?$query';

    try {
      http.Response response = await httpLog.get(
        Uri.parse(requestUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = BaseModel<PagingModel>.fromJson(
        jsonDecode(response.body),
        fromJsonT: (jsonT) =>
            PagingModel.fromJson(jsonT as Map<String, dynamic>),
      );

      BaseModel data1 = BaseModel<int>.binhPhuong(
        8,
        callback: (number) => number ?? 0,
      );

      print(data1.body);

      BaseModel data2 = BaseModel<int>.name2(
        jsonDecode(response.body),
        callback: (number) => number as int,
      );

      print(data2.body);

      if (data.success == true) {
        return data.body?.tasks;
      } else {
        throw Exception(data.message.toLang);
      }
    } on http.ClientException catch (_) {
      throw Exception();
    }
  }

  @override
  Future<http.Response> createTask(TaskBody body) async {
    String? token = SharedPrefs.token;

    const url = AppConstant.endPointTaskCreate;

    http.Response response = await httpLog.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body.toJson()),
    );

    return response;
  }

  @override
  Future<http.Response> updateTask(TaskBody body) async {
    String? token = SharedPrefs.token;

    final url = '${AppConstant.endPointTaskUpdate}/${body.id}';

    http.Response response = await httpLog.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body.toJson()),
    );

    return response;
  }

  @override
  Future<http.Response> deleteTask(String id) async {
    String? token = SharedPrefs.token;

    final url = '${AppConstant.endPointTaskDelete}/$id';

    http.Response response = await httpLog.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }

  @override
  Future<http.Response> deleteMultipleTask(DeleteTaskBody body) async {
    String? token = SharedPrefs.token;

    const url = AppConstant.endPointTaskMultipleDelete;

    http.Response response = await httpLog.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body.toJson()),
    );

    return response;
  }

  @override
  Future<http.Response> restoreMultipleTask(DeleteTaskBody body) async {
    String? token = SharedPrefs.token;

    const url = AppConstant.endPointTaskMultipleRestore;

    http.Response response = await httpLog.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body.toJson()),
    );

    return response;
  }
}
