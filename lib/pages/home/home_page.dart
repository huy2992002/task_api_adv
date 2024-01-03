import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:task_api_adv/components/snack_bar/td_snack_bar.dart';
import 'package:task_api_adv/components/snack_bar/top_snack_bar.dart';
import 'package:task_api_adv/pages/home/widgets/card_task.dart';
import 'package:task_api_adv/components/td_search_box.dart';
import 'package:task_api_adv/models/task_model.dart';
import 'package:task_api_adv/resources/app_color.dart';
import 'package:task_api_adv/services/remote/body/task_body.dart';
import 'package:task_api_adv/services/remote/task_services.dart';
import 'package:task_api_adv/utils/enum.dart';
import 'package:task_api_adv/services/remote/code_error.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();
  final addController = TextEditingController();
  final editController = TextEditingController();
  final addFocus = FocusNode();
  final editFocus = FocusNode();
  bool showAddBox = false;
  bool isLoading = false;
  bool isLoad = false;

  ///===========================///
  TaskServices taskServices = TaskServices();
  List<TaskModel> tasks = [];
  List<TaskModel> tasksSearch = [];

  @override
  void initState() {
    super.initState();
    // addController.addListener(() {
    //   setState(() {}); // lắng nghe và setState() khi TextField thay đổi
    // });
    _getTasks();
  }

  // Get List Task
  Future<void> _getTasks() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1600));

    final query = {'deleted': false};

    taskServices.getListTask(queryParams: query).then((value) {
      tasks = value ?? [];
      // tasksSearch = [...tasks];
      _search(searchController.text);
      setState(() => isLoading = false);
    }).catchError((onError) {
      String? error = onError.message;
      showTopSnackBar(
        context,
        TDSnackBar.error(
          message: error ?? 'Server error 😐',
        ),
      );
      setState(() => isLoading = false);
    });
  }

  void _createTask() {
    setState(() => isLoad = true);
    Timer(const Duration(milliseconds: 1600), () {
      final body = TaskBody()
        ..name = addController.text.trim()
        ..description = 'Hello World'
        ..status = StatusType.PROCESSING.name;
      taskServices.createTask(body).then((response) {
        final data = jsonDecode(response.body);
        if (data['status_code'] == 200) {
          // tasks.add(
          //     TaskModel.fromJson(TaskResponse.fromJson(data['body']).toJson()));
          tasks.add(TaskModel.fromJson(data['body']));
          addController.clear();
          tasksSearch = [...tasks];
          searchController.clear();
          setState(() => isLoad = false);
        } else {
          print('object message ${data['message']}');
          showTopSnackBar(
            context,
            TDSnackBar.error(
                message: (data['message'] as String?)?.toLang ?? '😐'),
          );
          setState(() => isLoad = false);
        }
      }).catchError((onError) {
        print('object $onError');
        showTopSnackBar(
          context,
          const TDSnackBar.error(message: "Server error add 😐"),
        );
        setState(() => isLoad = false);
      });
    });
  }

  void _updateTask(TaskBody body) {
    taskServices.updateTask(body).then((response) {
      final data = jsonDecode(response.body);
      if (data['status_code'] == 200) {
        tasks.singleWhere((element) => element.id == body.id)
          ..name = body.name
          ..description = body.description
          ..status = body.status;
        tasksSearch.singleWhere((element) => element.id == body.id)
          ..name = body.name
          ..description = body.description
          ..status = body.status;
        setState(() {});
      } else {
        print('object message ${data['message']}');
      }
    }).catchError((onError) {
      print('object $onError');
    });
  }

  void _deleteTask(String id) {
    taskServices.deleteTask(id).then((response) {
      final data = jsonDecode(response.body);
      if (data['status_code'] == 200) {
        tasks.removeWhere((element) => (element.id ?? '') == id);
        tasksSearch.removeWhere((element) => (element.id ?? '') == id);
        setState(() {});
      } else {
        print('object message ${data['message']}');
      }
    }).catchError((onError) {
      print('object $onError');
    });
  }

  void _search(String searchText) {
    searchText = searchText.toLowerCase();
    setState(() {
      tasksSearch = tasks
          .where((element) =>
              (element.name ?? '').toLowerCase().contains(searchText))
          .toList();
    });
  }

  void _onEdit(TaskModel task) {
    setState(() {
      // close all edit task before open new edit task
      for (var element in tasks) {
        element.isEditing = false;
      }
      task.isEditing = true;
      editController.text = task.name ?? '';
      editFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TdSearchBox(
                  controller: searchController,
                  onChanged: _search,
                ),
              ),
              const SizedBox(height: 16.0),
              const Divider(
                height: 2.0,
                indent: 20.0,
                endIndent: 20.0,
                color: AppColor.primary,
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColor.primary,
                  onRefresh: () async {
                    _getTasks();
                  },
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColor.primary),
                        )
                      : tasksSearch.isEmpty // && (isLoading == false)
                          ? Center(
                              child: Text(
                                searchController.text.isEmpty
                                    ? 'Tasks is empty'
                                    : 'There is no result',
                                style: const TextStyle(
                                    color: AppColor.brown, fontSize: 20.0),
                              ),
                            )
                          : SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ).copyWith(top: 16.0, bottom: 86.0),
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: tasksSearch.length,
                                reverse: true,
                                itemBuilder: (context, index) {
                                  TaskModel task = tasksSearch[index];
                                  return CardTask(
                                    task,
                                    editController: editController,
                                    editFocus: editFocus,
                                    onTap: () {
                                      final body = TaskBody()
                                        ..id = task.id
                                        ..name = task.name
                                        ..description = task.description
                                        ..status =
                                            task.status == StatusType.DONE.name
                                                ? StatusType.PROCESSING.name
                                                : StatusType.DONE.name;
                                      _updateTask(body);
                                    },
                                    onEdit: () => _onEdit(task),
                                    onLongPress: () => _onEdit(task),
                                    onSave: () {
                                      final body = TaskBody()
                                        ..id = task.id
                                        ..name = editController.text.trim()
                                        ..description = task.description
                                        ..status = task.status;
                                      _updateTask(body);
                                      setState(() {
                                        task.isEditing = false;
                                      });
                                    },
                                    onCancel: () {
                                      setState(() {
                                        task.isEditing = false;
                                      });
                                    },
                                    onDeleted: () {
                                      for (var element in tasks) {
                                        element.isConfirmDelete = false;
                                      }
                                      task.isConfirmDelete = true;
                                      setState(() {});
                                    },
                                    onHorizontalDragEnd: (details) {
                                      // if (details.primaryVelocity! > 0) {}
                                      for (var element in tasks) {
                                        element.isConfirmDelete = false;
                                      }
                                      task.isConfirmDelete = true;
                                      setState(() {});
                                    },
                                    onConfirmYes: () =>
                                        _deleteTask(task.id ?? ''),
                                    onConfirmNo: () {
                                      task.isConfirmDelete = false;
                                      setState(() {});
                                    },
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 16.0),
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20.0,
          right: 20.0,
          bottom: 12.0,
          child: Row(
            children: [
              Expanded(
                child: AnimatedScale(
                  scale: showAddBox ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 640),
                  alignment: Alignment.centerRight,
                  child: _addBox(),
                ),
              ),
              const SizedBox(width: 16.0),
              _addButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _addButton() {
    return GestureDetector(
      onTap: isLoad
          ? null
          : () {
              showAddBox = !showAddBox;
              setState(() {});
              if (showAddBox) {
                addFocus.requestFocus();
                return;
              }
              if (addController.text.isNotEmpty) {
                _createTask();
              }
              addFocus.unfocus();
            },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: AppColor.primary,
          border: Border.all(color: AppColor.red.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: const [
            BoxShadow(
              color: AppColor.shadow,
              offset: Offset(0.0, 2.0),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: isLoad
            ? const SizedBox.square(
                dimension: 32.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: AppColor.white,
                ),
              )
            : Icon(
                addController.text.isEmpty ? Icons.add : Icons.check,
                size: 32.0,
                color: AppColor.white,
              ),
      ),
    );
  }

  Widget _addBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.6, vertical: 3.6),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: AppColor.orange, width: 1.2),
        borderRadius: BorderRadius.circular(8.6),
        boxShadow: const [
          BoxShadow(
            color: AppColor.shadow,
            offset: Offset(0.0, 3.0),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: TextFormField(
        controller: addController,
        focusNode: addFocus,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Add a new todo item',
          hintStyle: TextStyle(color: AppColor.grey),
        ),
        onFieldSubmitted: (_) {
          showAddBox = !showAddBox;
          if (addController.text.isNotEmpty) {
            _createTask();
          }
          FocusScope.of(context).unfocus();
        },
        textInputAction: TextInputAction.done,
      ),
    );
  }
}
