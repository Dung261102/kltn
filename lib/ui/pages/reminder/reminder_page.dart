import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:glucose_real_time/controllers/task_controller.dart';
import 'package:glucose_real_time/ui/widgets/button.dart';
import 'package:glucose_real_time/ui/widgets/task_title.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../models/task.dart';
import '../../../services/notification_services.dart';
import '../../theme/theme.dart';
import '../../widgets/common_appbar.dart';
import 'add_task_bar.dart';


class ReminderPage extends StatefulWidget {
  const ReminderPage({Key? key}) : super(key: key);
  @override
  _RemiderPage createState() => _RemiderPage();
}

class _RemiderPage extends State<ReminderPage> {
  DateTime _selectedDate = DateTime.now();
  final _taskController = Get.put(TaskController());

  // Lấy instance NotifyHelper singleton
  final NotifyHelper notifyHelper = NotifyHelper();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("build method called");
    return Scaffold(
      appBar: CommonAppBar(
        notifyHelper: notifyHelper,
        // thêm code để chỉnh sửa app bar tại đây
      ),
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          SizedBox(height: 10),
          _showTask(),
        ],
      ),
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

          MyButton(
            label: "+ Add Task",
            onTap: () async {
              await Get.to(() => (AddTaskPage()));
              _taskController.getTask();
            },
          ),
        ],
      ),
    );
  }

  _showTask() {
    return Expanded(
      child: Obx(() {
        return ListView.builder(
          itemCount: _taskController.taskList.length,
          itemBuilder: (_, index) {
            Task task = _taskController.taskList[index];
            print(task.toJson()); // Debug thông tin task

            if (task.repeat == 'Daily' && task.isCompleted != 1) {
              String cleanedTime = task.startTime.toString().trim();
// Nếu cần, có thể dùng regex để loại bỏ ký tự không phải số, chữ, hoặc dấu hai chấm, AM/PM
              cleanedTime = cleanedTime.replaceAll(RegExp(r'[^\d:APM ]'), '').trim();

              // DateFormat format = DateFormat('hh:mm a'); // hh: giờ 12h, mm: phút, a: AM/PM
              // DateTime date = format.parse(cleanedTime);

              //test
              DateTime date;

              try {
                // Thử parse với định dạng có AM/PM
                DateFormat format = DateFormat('hh:mm a'); // hh: giờ 12h, mm: phút, a: AM/PM
                date = format.parse(cleanedTime);
              } catch (e) {
                // Nếu lỗi, parse với định dạng 24h
                DateFormat format = DateFormat('HH:mm'); // HH: giờ 24h, mm: phút
                date = format.parse(cleanedTime);
              }


              var myTime = DateFormat('HH:mm').format(date);

              int hour = date.hour;
              int minutes = date.minute;


              // print('Original startTime: "${task.startTime.toString()}"');
              // print('Cleaned startTime: "$cleanedTime"');
              // print('Hour: $hour, Minutes: $minutes');



              // DateTime date = DateFormat.jm().parse(task.startTime.toString());
              // var myTime = DateFormat("HH:mm").format(date);
              print(myTime);
              notifyHelper.scheduledNotification(hour, minutes, task);

              return AnimationConfiguration.staggeredList(
                position: index,
                child: SlideAnimation(
                  child: FadeInAnimation(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showBottomSheet(context, task);
                          },
                          child: TaskTile(task),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (task.date == DateFormat.yMd().format(_selectedDate)) {
              return AnimationConfiguration.staggeredList(
                position: index,
                child: SlideAnimation(
                  child: FadeInAnimation(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showBottomSheet(context, task);
                          },
                          child: TaskTile(task),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Container();
            }
          },
        );
      }),
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 4),
        height:
            task.isCompleted == 1
                ? MediaQuery.of(context).size.height * 0.24
                : MediaQuery.of(context).size.height * 0.32,
        width:
            MediaQuery.of(
              context,
            ).size.width, // ✅ Thêm dòng này để full chiều ngang
        color: Get.isDarkMode ? darkGreyClr : Colors.white,
        child: Column(
          children: [
            Container(
              height: 6,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
              ),
            ),
            Spacer(),
            task.isCompleted == 1
                ? Container()
                : _bottomSheetButton(
                  label: "Task Completed",
                  onTap: () {
                    _taskController.markTaskCompleted(task.id!);
                    Get.back();
                  },
                  clr: primaryClr,
                  context: context,
                ),
            // IconButton(
            //   icon: Icon(Icons.delete_forever),
            //   onPressed: () {
            //     _taskController.deleteAllTasks();
            //     Get.snackbar("Xóa tất cả", "Toàn bộ công việc đã được xoá",
            //         snackPosition: SnackPosition.BOTTOM);
            //   },
            // ),


            SizedBox(height: 20),

            _bottomSheetButton(
              label: "Delete Task",
              onTap: () {
                _taskController.delete(task);
                Get.back();
              },
              clr: Colors.red[300]!,
              context: context,
            ),




            SizedBox(height: 20),

            _bottomSheetButton(
              label: "Close",
              onTap: () {
                Get.back();
              },
              clr: Colors.red[300]!,
              context: context,
              isClose: true,
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  _bottomSheetButton({
    required String label,
    required Function()? onTap,
    required Color clr,
    bool isClose = false,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 55,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color:
                isClose == true
                    ? Get.isDarkMode
                        ? Colors.grey[600]!
                        : Colors.grey[300]!
                    : clr,
          ),
          borderRadius: BorderRadius.circular(20),
          color: isClose == true ? Colors.transparent : clr,
        ),
        child: Center(
          child: Text(
            label,
            style:
                isClose ? titleStyle : titleStyle.copyWith(color: Colors.white),
          ),
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
          setState(() {
            _selectedDate = date;
          });
        },
      ),
    );
  }
}
