import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:todo_list_demo/data/model/todo_model.dart';
import 'package:todo_list_demo/home/home_page.dart';

class TodoListProvider with ChangeNotifier {
  setLoading(bool value) {
    configLoading();
    value ? EasyLoading.show(status: 'Loading') : EasyLoading.dismiss();
  }

  final db = FirebaseFirestore.instance;
  static const String TODO_LIST_COLECTION = 'todo-list';

  List<TodoListModel> todoLists = [];
  List<String> todoIdList = [];
  bool isEmpty = false;

  TodoListProvider() {
    initData();
  }

  Future initData() async {
    setLoading(true);
    final repo = db.collection(TODO_LIST_COLECTION);
    await repo.get().then((value) {
      setLoading(false);
      value.docs.map((doc) {
        todoIdList.add(doc.id);
        todoLists.add(TodoListModel.fromJson(doc.data()));
      }).toList();
      notifyListeners();
    }).onError((error, stackTrace) {
      setLoading(false);
    });
  }

  Future refreshData() async {
    todoIdList = [];
    todoLists = [];
    final repo = db.collection(TODO_LIST_COLECTION);
    await repo.get().then((value) {
      setLoading(false);
      value.docs.map((doc) {
        todoIdList.add(doc.id);
        todoLists.add(TodoListModel.fromJson(doc.data()));
      }).toList();
      notifyListeners();
    }).onError((error, stackTrace) {
      setLoading(false);
    });
  }

  filterData(String filter) {
    todoLists = todoLists
        .where(
            (test) => test.title.toLowerCase().contains(filter.toLowerCase()))
        .toList();
    notifyListeners();
  }

  Future addTodoList(TodoListModel todoParams) async {
    setLoading(true);
    //todoLists = [];
    final repo = db.collection(TODO_LIST_COLECTION);
    if (todoLists.every((element) =>
            element.title.toLowerCase() != todoParams.title.toLowerCase()) &&
        todoParams.title != '') {
      await repo.doc().set({
        'id': repo.doc().id,
        'title': todoParams.title,
        'status': false
      }).then((res) async {
        refreshData();
      }).onError((error, stackTrace) => setLoading(false));
    } else {
      showToast(todoParams.title == ""
          ? "your todo must not be null"
          : "this title is already have");
      setLoading(false);
    }
  }

  Future deleteTodoList(String id) async {
    setLoading(true);
    //print("....................Doc id ${id}");
    final repo = db.collection(TODO_LIST_COLECTION);
    await repo.doc(id).delete().then((res) async {
      refreshData();
      showToast("your todo is have been delete");
    }).onError((error, stackTrace) {
      setLoading(false);
    });
  }

  Future updateTodoList(String id, TodoListModel todoParams) async {
    setLoading(true);
    final repo = db.collection(TODO_LIST_COLECTION);
    if (todoParams.title != '') {
      await repo.doc(id).update({
        'title': todoParams.title,
        'status': todoParams.status
      }).then((res) async {
        refreshData();
        showToast("Your todo have been updated");
      }).onError((error, stackTrace) {
        setLoading(false);
      });
    } else {
      showToast("title could not be empty");
      setLoading(false);
    }
  }

  static void configLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.ring
      //..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 55.0
      ..radius = 10.0
      ..progressColor = Colors.white
      ..backgroundColor = Colors.black
      ..indicatorColor = Colors.white
      ..textColor = Colors.white
      //..maskType = EasyLoadingMaskType.black
      ..maskColor = Colors.black.withOpacity(0.7)
      ..userInteractions = true
      ..dismissOnTap = true;
  }
}
