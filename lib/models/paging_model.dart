import 'package:task_api_adv/models/task_model.dart';

class PagingModel {
  List<TaskModel>? tasks;
  int? totalDocs;
  int? limit;
  int? totalPages;
  int? page;
  int? pagingCounter;
  bool? hasPrevPage;
  bool? hasNextPage;
  int? prevPage;
  int? nextPage;

  PagingModel({
    this.tasks,
    this.totalDocs,
    this.limit,
    this.totalPages,
    this.page,
    this.pagingCounter,
    this.hasPrevPage,
    this.hasNextPage,
    this.prevPage,
    this.nextPage,
  });

  Map<String, dynamic> toJson() {
    return {
      'docs': tasks,
      'totalDocs': totalDocs,
      'limit': limit,
      'totalPages': totalPages,
      'page': page,
      'pagingCounter': pagingCounter,
      'hasPrevPage': hasPrevPage,
      'hasNextPage': hasNextPage,
      'prevPage': prevPage,
      'nextPage': nextPage,
    };
  }

  factory PagingModel.fromJson(Map<String, dynamic> json) {
    return PagingModel(
      tasks: (json['docs'] as List<dynamic>?)
          ?.map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalDocs: json['totalDocs'] as int?,
      limit: json['limit'] as int?,
      totalPages: json['totalPages'] as int?,
      page: json['page'] as int?,
      pagingCounter: json['pagingCounter'] as int?,
      hasPrevPage: json['hasPrevPage'] as bool?,
      hasNextPage: json['hasNextPage'] as bool?,
      prevPage: json['prevPage'] as int?,
      nextPage: json['nextPage'] as int?,
    );
  }

  @override
  String toString() =>
      "Body(docs: $tasks,totalDocs: $totalDocs,limit: $limit,totalPages: $totalPages,page: $page,pagingCounter: $pagingCounter,hasPrevPage: $hasPrevPage,hasNextPage: $hasNextPage,prevPage: $prevPage,nextPage: $nextPage)";

  @override
  int get hashCode => Object.hash(tasks, totalDocs, limit, totalPages, page,
      pagingCounter, hasPrevPage, hasNextPage, prevPage, nextPage);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PagingModel &&
          runtimeType == other.runtimeType &&
          tasks == other.tasks &&
          totalDocs == other.totalDocs &&
          limit == other.limit &&
          totalPages == other.totalPages &&
          page == other.page &&
          pagingCounter == other.pagingCounter &&
          hasPrevPage == other.hasPrevPage &&
          hasNextPage == other.hasNextPage &&
          prevPage == other.prevPage &&
          nextPage == other.nextPage;
}
