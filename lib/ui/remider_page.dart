import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:glucose_real_time/controllers/task_controller.dart';
import 'package:glucose_real_time/services/theme_service.dart';
import 'package:glucose_real_time/ui/add_task_bar.dart';
import 'package:glucose_real_time/ui/theme.dart';
import 'package:glucose_real_time/ui/widgets/button.dart';
import 'package:glucose_real_time/ui/widgets/task_title.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../services/notification_services.dart';

class RemiderPage extends StatefulWidget {
  const RemiderPage({super.key});
  @override
  _RemiderPage createState() => _RemiderPage();
}

class _RemiderPage extends State<RemiderPage> {
  DateTime _selectedDate = DateTime.now();
  final _taskController = Get.put(TaskController());
  var notifyHelper;
  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    //Hàm cấp quyền cho IOS
    notifyHelper.requestIOSPermissions();
    //  Hàm cấp quyền cho android
    notifyHelper.requestAndroidNotificationPermission();
  }

  @override
  Widget build(BuildContext context) {
    print("build method called");
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: Column(
          children: [
            _addTaskBar(),
            _addDateBar(),
            SizedBox(height: 10,),
            _showTask(),
          ]
      ),
    );
  }

  //thanh trên cùng
  _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      leading: GestureDetector(
        onTap: () {
          ThemeService().switchTheme();
          notifyHelper.displayNotification(
            title: "Theme Changed",
            body:
                Get.isDarkMode
                    ? "Activated Light Theme"
                    : "Activated Dark Theme",
          );

          notifyHelper.scheduledNotification(); //chưa sử dụng được
        },
        child: Icon(
          Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
          size: 20,
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      actions: [
        CircleAvatar(backgroundImage: AssetImage("images/profile.png")),

        SizedBox(width: 20),
      ],
    );
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMMd().format(DateTime.now()),
                  style: subHeadingStyle,
                ),

                Text("Today", style: headingStyle),
              ],
            ),
          ),

          MyButton(label: "+ Add Task", onTap: ()async{
            await Get.to(()=>(AddTaskPage()));
            _taskController.getTask();
          }
          )
        ],
      ),
    );
  }




  _showTask() {
    return Expanded(
        child: Obx((){
          return ListView.builder(
            itemCount: _taskController.taskList.length,
              itemBuilder: (_, index) {
              print(_taskController.taskList.length);
              return AnimationConfiguration.staggeredList(
                  position: index,
                  child: SlideAnimation(
                      child: FadeInAnimation(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: (){
                                  _showBottomSheet(context, _taskController.taskList[index]);
                                },
                                child: TaskTile(_taskController.taskList[index]),
                              )

                            ],
                          )
                      )
                  )
              );


          });

        }),
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
        Container(
          padding: const EdgeInsets.only(top: 4),
          height: task.isCompleted==1?
          MediaQuery.of(context).size.height*0.24:
          MediaQuery.of(context).size.height*0.32,
          color: Get.isDarkMode?darkGreyClr:Colors.white,
          child: Column(
            children: [
              Container(
                height: 6,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Get.isDarkMode?Colors.grey[600]:Colors.grey[300]
                ),
              )
            ],
          ),

        ),
    );

  }

  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20),
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,

        initialSelectedDate: DateTime.now(),
        selectionColor: primaryClr,
        selectedTextColor: Colors.white,

        dateTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),

        dayTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),

        monthTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),

        onDateChange: (date) {
          _selectedDate = date;
        },
      ),
    );
  }
}
