import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_screen.dart';
import 'package:todo_app/modules/done_screen.dart';
import 'package:todo_app/modules/tasks_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);
  int currentIndex = 0;
  List<Widget> screens = [TasksScreen(), DoneScreen(), ArchivedScreen()];
  List<String> titles = ["New Tasks", "Done Tasks", "Archived Tasks"];
  void changeIndex(int index) {
    currentIndex = index;
    emit(AppBottomNavState());
  }

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  Database database;
  void createDatabase() {
    openDatabase(
      "todo.db",
      version: 1,
      onCreate: (db, version) {
        print("database created");
        db
            .execute(
                "CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT , status TEXT)")
            .then((value) {
          print("database created");
        }).catchError((error) {
          print(
            "error is ${error.toString()}",
          );
        });
      },
      onOpen: (database) {
        getFromDatabase(database);
      },
    ).then((value) {
      database = value;
      emit(CreateDatabaseState());
    });
  }

  Future insertIntoDatabase({
    @required String title,
    @required String date,
    @required String time,
  }) async {
    return await database.transaction((txn) {
      txn
          .rawInsert(
        'INSERT INTO tasks(title, date, time , status) VALUES("$title","$date","$time","new")',
      )
          .then((value) {
        print("$value inserted successfully");
        emit(InsertIntoDatabaseState());
        getFromDatabase(database);
      }).catchError((error) {
        print("error is${error.toString()}");
      });
      return;
    });
  }

  void getFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(GetFromDatabaseLoadingState());
    database.rawQuery("SELECT * FROM tasks").then((value) {
      value.forEach((element) {
        if (element["status"] == "new") {
          newTasks.add(element);
        } else if (element["status"] == "done") {
          doneTasks.add(element);
        } else
          archivedTasks.add(element);
      });
      emit(GetFromDatabaseState());
    });
  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;
  void changeBottomSheetState({bool isShow, IconData icon}) {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(BottomSheetState());
  }

  void updateData({@required String status, @required int id}) async {
    await database.rawUpdate('UPDATE tasks SET status = ?  WHERE id = ?', [
      '$status',
      id,
    ]).then((value) {
      getFromDatabase(database);
      emit(UpdateDataState());
    });
  }

  void deleteData({@required int id}) async {
    await database
        .rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getFromDatabase(database);
      emit(DeleteDataState());
    });
  }
}
