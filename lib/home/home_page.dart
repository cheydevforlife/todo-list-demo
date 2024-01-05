import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_demo/data/model/todo_model.dart';
import 'package:todo_list_demo/home/store/todo_list_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoListProvider(),
      child: HomePageContainer(),
    );
  }
}

class HomePageContainer extends StatefulWidget {
  HomePageContainer();

  @override
  HomePageContainerState createState() => HomePageContainerState();
}

class HomePageContainerState extends State<HomePageContainer> {
  final _textEditController = TextEditingController();
  bool isFilter = false;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TodoListProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Todo List"),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [

            //Top search bar
            TextField(
              cursorColor: Colors.grey,
              controller: _textEditController,
              onChanged: (value) {
                if (value == '') {
                  isFilter = false;
                  state.refreshData();
                } else {
                  isFilter = true;
                  state.filterData(value);
                }
              },
              //onSubmitted: (value) {},
              decoration: const InputDecoration(
                prefixIcon: Icon(size: 17.6, Icons.search, color: Colors.grey),
                isDense: true,
                hintText: "Type to filter",
                hintStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.0,
                    color: Colors.grey),
                border: InputBorder.none,
              ),
            ),

            state.todoLists.isEmpty && isFilter
                ? const Center(child: Text("No result"))
                : SingleChildScrollView(
                    child: Column(
                      //List item
                      children: state.todoLists
                          .asMap()
                          .map((i, e) {
                            return MapEntry( i,
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            //Todo Checkbox
                                            Visibility(
                                              visible: !isFilter,
                                              replacement: SizedBox(width: 20),
                                              child: Checkbox(
                                                value: e.status,
                                                activeColor: Colors.pink[500],
                                                onChanged: (newValue) {
                                                  final todoParams =
                                                      TodoListModel(
                                                          id: e.id,
                                                          title: e.title,
                                                          status: newValue!);
                                                  state.updateTodoList(
                                                      state.todoIdList[i],
                                                      todoParams);
                                                },
                                              ),
                                            ),
                                            //Todo title widget
                                            Expanded(
                                                child: Text(
                                              e.title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge?.copyWith(
                                                    decoration: e.status && !isFilter ? TextDecoration.lineThrough
                                                    : TextDecoration.none
                                                  ),
                                            )),

                                            //Icon button delete widget
                                            Visibility(
                                              visible: !isFilter,
                                              child: IconButton(
                                                onPressed: () {
                                                  if (state.todoIdList.length ==
                                                      1) {
                                                    showToast(
                                                        "Item must not empty");
                                                  } else {
                                                    Provider.of<TodoListProvider>(
                                                            context,
                                                            listen: false)
                                                        .deleteTodoList(state
                                                            .todoIdList[i]);
                                                  }
                                                },
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.grey),
                                              ),
                                            ),
                                            //Icon button upate widget
                                            Visibility(
                                              visible: !isFilter,
                                              child: IconButton(
                                                onPressed: () {
                                                  showSheet(context, false,
                                                      textValue: e.title,
                                                      status: e.status,
                                                      todoId: state.todoIdList[i]);
                                                },
                                                icon: const Icon(
                                                    Icons.edit_note,
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          ]),
                                    ),
                                    const Divider(height: 0)
                                  ],
                                ));
                          })
                          .values
                          .toList(),
                    ),
                  ),
          ],
        ),
      ),

      //Floating button add and edit
      floatingActionButton: Visibility(
        visible: !isFilter,
        child: FloatingActionButton(
          heroTag: "fab_button",
          backgroundColor: Colors.pink[500],
          elevation: 3,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            showSheet(context, true);
          },
        ),
      ),
    );
  }
}

void showSheet(context, bool isAdd, {String? textValue, bool? status, String? todoId}) {
  final _textEditController = TextEditingController();

  _textEditController.text = textValue ?? '';
  FocusNode focusNode = FocusNode();
  const TextStyle(color: Colors.white, height: 1.4, fontSize: 16);
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    height: 20,
                  ),
                  Container(height: 15),
                  // Enter input text
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 1,
                    margin: const EdgeInsets.all(0),
                    child: Container(
                      height: 45,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: TextField(
                        maxLines: 1,
                        controller: _textEditController,
                        focusNode: focusNode,
                        autofocus: true,
                        onSubmitted: (value) {
                          final todoParams = TodoListModel(
                              id: "", title: value, status: status ?? false);
                          if (isAdd) {
                            Provider.of<TodoListProvider>(context,
                                    listen: false)
                                .addTodoList(todoParams)
                                .then((value) => _textEditController.text = '');
                          } else {
                            Provider.of<TodoListProvider>(context,
                                    listen: false)
                                .updateTodoList(todoId!, todoParams)
                                .then((value) => _textEditController.text = '');
                          }
                        },
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(-12),
                            border: InputBorder.none,
                            hintText: "What you want to do?"),
                      ),
                    ),
                  ),
                  Container(height: 15),

                  //Button submit
                  Padding(
                      padding: const EdgeInsets.only(left: 60, right: 60),
                      child: SizedBox(
                        width: double.infinity, // match_parent
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink[500],
                          ),
                          child: const Text(
                            "Submit",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            final todoParams = TodoListModel(
                                id: "",
                                title: _textEditController.text,
                                status: status ?? false);
                            if (isAdd) {
                              Provider.of<TodoListProvider>(context,
                                      listen: false)
                                  .addTodoList(todoParams)
                                  .then(
                                      (value) => _textEditController.text = '');
                            } else {
                              Provider.of<TodoListProvider>(context,
                                      listen: false)
                                  .updateTodoList(todoId!, todoParams)
                                  .then(
                                      (value) => _textEditController.text = '');
                            }
                          },
                        ),
                      )),
                  Container(
                    height: 10,
                  )
                ],
              ),
            ),
          ),
        );
      });
}

void showToast(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      textColor: Colors.white,
      backgroundColor: Colors.black.withOpacity(0.7),
      fontSize: 12.0);
}

BoxDecoration myBoxDecoration() {
  return BoxDecoration(
    border: Border.all(
        width: 1, //
        color: Colors.grey[400]! //                  <--- border width here
        ),
  );
}
