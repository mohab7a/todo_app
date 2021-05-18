import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultFormField({
  @required TextEditingController controller,
  @required String label,
  Function onChange,
  Function onTap,
  Function onSubmit,
  @required Function validate,
  @required IconData prefix,
  @required TextInputType type,
}) =>
    TextFormField(
      onChanged: onChange,
      onTap: onTap,
      onFieldSubmitted: onSubmit,
      keyboardType: type,
      validator: validate,
      controller: controller,
      decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
          prefixIcon: Icon(prefix)),
    );

Widget buildTaskItem(Map model, context) => Dismissible(
      key: Key(model["id"].toString()),
      onDismissed: (direction) {
        AppCubit.get(context).deleteData(id: model["id"]);
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(model["time"]),
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  model["title"],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  model["date"],
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            Expanded(
              child: SizedBox(
                width: 20,
              ),
            ),
            IconButton(
                icon: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                onPressed: () {
                  AppCubit.get(context)
                      .updateData(status: "done", id: model["id"]);
                }),
            IconButton(
                icon: Icon(
                  Icons.archive,
                  color: Colors.grey,
                ),
                onPressed: () {
                  AppCubit.get(context)
                      .updateData(status: "archived", id: model["id"]);
                })
          ],
        ),
      ),
    );
Widget tasksBuilder({@required List<Map> tasks}) => ConditionalBuilder(
      condition: tasks.length > 0,
      fallback: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu,
              size: 100,
              color: Colors.grey,
            ),
            Text(
              "No Tasks Yet, Please Add Some Tasks",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      builder: (context) => ListView.separated(
          itemBuilder: (context, index) => buildTaskItem(tasks[index], context),
          separatorBuilder: (context, index) => Container(
                color: Colors.grey[300],
                width: double.infinity,
                height: 1,
              ),
          itemCount: tasks.length),
    );
