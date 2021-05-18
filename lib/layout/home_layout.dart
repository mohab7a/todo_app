import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';
import 'package:todo_app/shared/widgets/default_form_field.dart';

class HomeLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
          listener: (context, AppStates state) {},
          builder: (context, AppStates state) {
            AppCubit cubit = AppCubit.get(context);
            return Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                title: Text(cubit.titles[cubit.currentIndex]),
              ),
              body: ConditionalBuilder(
                condition: state is! GetFromDatabaseLoadingState,
                builder: (context) => cubit.screens[cubit.currentIndex],
                fallback: (context) => Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                child: Icon(cubit.fabIcon),
                onPressed: () {
                  if (cubit.isBottomSheetShown) {
                    if (formKey.currentState.validate()) {
                      cubit
                          .insertIntoDatabase(
                              date: dateController.text,
                              time: timeController.text,
                              title: titleController.text)
                          .then((value) {
                        Navigator.pop(context);
                        cubit.changeBottomSheetState(
                            isShow: false, icon: Icons.edit);
                      });
                    }
                  } else {
                    scaffoldKey.currentState
                        .showBottomSheet(
                            (context) => Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.all(20),
                                  child: Form(
                                    key: formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        defaultFormField(
                                            controller: titleController,
                                            label: "Task Title",
                                            validate: (String value) {
                                              if (value.isEmpty) {
                                                return "Task Title Must Not Be Empty";
                                              }
                                            },
                                            prefix: Icons.title,
                                            type: TextInputType.text),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        defaultFormField(
                                            controller: timeController,
                                            label: "Task Time",
                                            onTap: () {
                                              showTimePicker(
                                                      context: context,
                                                      initialTime:
                                                          TimeOfDay.now())
                                                  .then((value) {
                                                timeController.text =
                                                    value.format(context);
                                              });
                                            },
                                            validate: (value) {
                                              if (value.isEmpty) {
                                                return "Task Time Must Not Be Empty";
                                              }
                                            },
                                            prefix: Icons.timer,
                                            type: TextInputType.datetime),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        defaultFormField(
                                            controller: dateController,
                                            label: "Task Date",
                                            onTap: () {
                                              showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime.now(),
                                                      lastDate: DateTime.parse(
                                                          "2021-07-01"))
                                                  .then((value) {
                                                dateController.text =
                                                    DateFormat.yMMMd()
                                                        .format(value);
                                              });
                                            },
                                            validate: (value) {
                                              if (value.isEmpty) {
                                                return "Task Date Must Not Be Empty";
                                              }
                                            },
                                            prefix: Icons.calendar_today,
                                            type: TextInputType.datetime)
                                      ],
                                    ),
                                  ),
                                ),
                            elevation: 20)
                        .closed
                        .then((value) {
                      cubit.changeBottomSheetState(
                          isShow: false, icon: Icons.edit);
                    });
                    cubit.changeBottomSheetState(isShow: true, icon: Icons.add);
                  }
                },
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: cubit.currentIndex,
                onTap: (value) {
                  cubit.changeIndex(value);
                },
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.menu), label: "TASKS"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.check_circle_outline), label: "DONE"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.archive), label: "ARCHIVED"),
                ],
              ),
            );
          }),
    );
  }
}
