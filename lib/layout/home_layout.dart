import 'package:conditional_builder/conditional_builder.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_list/modules/Archived/archived_tasks_screen.dart';
import 'package:to_do_list/modules/Done/done_tasks_screen.dart';
import 'package:to_do_list/modules/Tasks/tasks_screen.dart';
import 'package:to_do_list/shared/components/components.dart';
import 'package:to_do_list/shared/components/constanats.dart';
import 'package:to_do_list/shared/cubit/cubit.dart';
import 'package:to_do_list/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  Database database;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {
          if(state is AppInsertDataBaseState){
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppStates state) {

          AppCubit cubit =  AppCubit.get(context);

          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.teal,
              title: Text(
                cubit.titles[cubit.currentIndex],
              ),
            ),
            body: ConditionalBuilder(
              builder: (context) =>  cubit.screens[cubit.currentIndex],
              condition: state is! AppGetDataBaseLoadingState,
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetIsShown) {
                  if (formKey.currentState.validate()) {
                     cubit.insertToDatabase(title: titleController.text, time: timeController.text, date: dateController.text);
                    // insertToDatabase(
                    //   title: titleController.text,
                    //   date: dateController.text,
                    //   time: timeController.text,
                    // ).then((value) {
                    //   getDataFromDatabase(database).then((value) {
                    //     Navigator.pop(context);
                    //     // setState(() {
                    //     //   isBottomSheetIsShown = false;
                    //     //   fabIcon = Icons.edit;
                    //     //
                    //     //   tasks = value;
                    //     // });
                    //   });
                    // });
                  }
                } else {
                  scaffoldKey.currentState
                      .showBottomSheet(
                        (context) => Container(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  defaultFormField(
                                    controller: titleController,
                                    prefix: Icons.title,
                                    type: TextInputType.text,
                                    label: 'Task Title',
                                    validate: (String value) {
                                      if (value.isEmpty) {
                                        return 'Title must not be empty';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                  defaultFormField(
                                    onTab: () {
                                      showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      ).then((value) {
                                        timeController.text =
                                            value.format(context).toString();
                                        print(value.format(context));
                                      });
                                    },
                                    controller: timeController,
                                    prefix: Icons.watch_later_outlined,
                                    type: TextInputType.datetime,
                                    label: 'Task Time',
                                    validate: (String value) {
                                      if (value.isEmpty) {
                                        return 'Time must not be empty';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                  defaultFormField(
                                    onTab: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.parse('2021-12-31'),
                                      ).then((value) {
                                        dateController.text =
                                            DateFormat.yMMMd().format(value);
                                      });
                                    },
                                    controller: dateController,
                                    prefix: Icons.calendar_today_outlined,
                                    type: TextInputType.datetime,
                                    label: 'Task Date',
                                    validate: (String value) {
                                      if (value.isEmpty) {
                                        return 'Date must not be empty';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        backgroundColor: Colors.grey[300],
                        elevation: 40.0,
                      )
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState(
                      icon: Icons.edit,
                      isShow: false,
                    );
                  });
                  cubit.changeBottomSheetState(isShow: true, icon: Icons.add,);
                }
              },
              child: Icon(
                cubit.fabIcon,
                color: Colors.black,
              ),
              backgroundColor: Colors.teal,
            ),
            bottomNavigationBar: CurvedNavigationBar(
                color: Colors.teal ,
                backgroundColor: Colors.white,
                buttonBackgroundColor: Colors.white,
                height: 50.0,
                animationDuration: Duration(
                  milliseconds: 150,
                ),
                animationCurve: Curves.bounceInOut,
                items: [
                  Icon(
                    Icons.list,
                  ),
                  Icon(
                    Icons.check_circle,
                  ),
                  Icon(
                    Icons.archive_outlined,
                  ),
                ],

              onTap: (index) {
                cubit.changeIndex(index);
              },
            )

          );
        },
      ),
    );
  }

  // Future<String> getName() async {
  //   return 'Ahmed Ali';
  // }


}
