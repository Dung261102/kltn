import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Quản lý trạng thái và điều hướng
import 'package:glucose_real_time/controllers/task_controller.dart'; // Controller quản lý task
import 'package:glucose_real_time/ui/widgets/button.dart'; // Widget nút bấm tùy chỉnh
import 'package:glucose_real_time/ui/widgets/input_field.dart'; // Widget input tùy chỉnh
import 'package:intl/intl.dart'; // Định dạng thời gian

// Các tài nguyên theme và model
import '../../../models/task.dart'; // Model Task
import '../../theme/theme.dart'; // Theme chung

// Widget chính cho màn hình thêm task
class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

// State chứa toàn bộ logic và UI của màn hình
class _AddTaskPageState extends State<AddTaskPage> {
  // Khởi tạo controller quản lý task
  final TaskController _taskController = Get.put(TaskController());

  // Các controller cho input tiêu đề và ghi chú
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // Biến quản lý ngày, giờ và các giá trị người dùng chọn
  DateTime _selectedDate = DateTime.now();
  String _endTime = "9:30 PM";
  String _startTime = DateFormat("hh:mm a").format(DateTime.now()).toString();
  int _selectedRemind = 5;
  List<int> remindList = [5, 10, 15, 20];

  String _selectedRepeat = "None";
  List<String> repeatList = ["None", "Daily", "Weekly", "Monthly"];

  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    // UI chính của trang AddTask
    return Scaffold(
      appBar: _appBar(context), // App bar tùy chỉnh

      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("Add Task", style: headingStyle), // Tiêu đề

              // Các input field cho title và note
              MyInputField(
                title: "Title",
                hint: "Enter your title",
                controller: _titleController,
              ),
              MyInputField(
                title: "Note",
                hint: "Enter your note",
                controller: _noteController,
              ),

              // Chọn ngày
              MyInputField(
                title: "Date",
                hint: DateFormat.yMd().format(_selectedDate),
                widget: IconButton(
                  icon: Icon(Icons.calendar_today_outlined),
                  color: Colors.grey,
                  onPressed: () {
                    _getDateFromUser();
                  },
                ),
              ),

              // Chọn giờ bắt đầu và kết thúc
              Row(
                children: [
                  Expanded(
                    child: MyInputField(
                      title: "Start Date",
                      hint: _startTime,
                      widget: IconButton(
                        onPressed: () {
                          _getTimeFromUser(isStartTime: true);
                        },
                        icon: Icon(Icons.access_time_rounded, color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: MyInputField(
                      title: "End Date",
                      hint: _endTime,
                      widget: IconButton(
                        onPressed: () {
                          _getTimeFromUser(isStartTime: false);
                        },
                        icon: Icon(Icons.access_time_rounded, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),

              // Dropdown chọn thời gian nhắc nhở
              MyInputField(
                title: "Remind",
                hint: "$_selectedRemind minutes early",
                widget: DropdownButton(
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  iconSize: 32,
                  elevation: 4,
                  style: subTitleStyle,
                  underline: Container(height: 0),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRemind = int.parse(newValue!);
                    });
                  },
                  items: remindList.map<DropdownMenuItem<String>>((int value) {
                    return DropdownMenuItem<String>(
                      value: value.toString(),
                      child: Text(value.toString()),
                    );
                  }).toList(),
                ),
              ),

              // Dropdown chọn chế độ lặp lại
              MyInputField(
                title: "Repeat",
                hint: _selectedRepeat,
                widget: DropdownButton(
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  iconSize: 32,
                  elevation: 4,
                  style: subTitleStyle,
                  underline: Container(height: 0),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRepeat = newValue!;
                    });
                  },
                  items: repeatList.map<DropdownMenuItem<String>>((String? value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value!, style: TextStyle(color: Colors.grey)),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 18),

              // Chọn màu và nút tạo task
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _colorPallete(), // Bảng màu chọn màu cho task
                  MyButton(label: "Create Task", onTap: () => _validateDate()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm kiểm tra đầu vào
  _validateDate() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      _addTaskToDb(); // Gọi hàm thêm task vào DB
      Get.back(); // Quay về màn hình trước
    } else {
      Get.snackbar(
        "Required",
        "All fields are required!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: pinkClr,
        icon: Icon(Icons.warning_amber_rounded, color: Colors.red),
      );
    }
  }

  // Hàm thêm task vào database thông qua controller
  _addTaskToDb() async {
    int value = await _taskController.addTask(
      task: Task(
        note: _noteController.text,
        title: _titleController.text,
        date: DateFormat.yMd().format(_selectedDate),
        startTime: _startTime,
        endTime: _endTime,
        remind: _selectedRemind,
        repeat: _selectedRepeat,
        color: _selectedColor,
        isCompleted: 0,
      ),
    );
    print("My id is " + "$value");
  }

  // Widget bảng chọn màu
  _colorPallete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Color", style: titleStyle),
        SizedBox(height: 8.0),
        Wrap(
          children: List<Widget>.generate(3, (int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: index == 0
                      ? primaryClr
                      : index == 1
                      ? pinkClr
                      : yellowClr,
                  child: _selectedColor == index
                      ? Icon(Icons.done, color: Colors.white, size: 16)
                      : Container(),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // App bar tuỳ chỉnh cho trang này
  _appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.arrow_back_ios,
          size: 20,
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      actions: [
        CircleAvatar(backgroundImage: AssetImage("assets/images/profile/avatar.jpg")),
        SizedBox(width: 20),
      ],
    );
  }

  // Hàm hiển thị DatePicker và cập nhật ngày chọn
  _getDateFromUser() async {
    DateTime? _pickerData = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (_pickerData != null) {
      setState(() {
        _selectedDate = _pickerData;
      });
    }
  }

  // Hàm hiển thị TimePicker cho thời gian bắt đầu/kết thúc
  _getTimeFromUser({required bool isStartTime}) async {
    var pickerTime = await _showTimePicker();
    if (pickerTime == null) return;

    String _formatedTime = pickerTime.format(context);
    setState(() {
      if (isStartTime)
        _startTime = _formatedTime;
      else
        _endTime = _formatedTime;
    });
  }

  // Hàm gọi TimePicker
  _showTimePicker() {
    return showTimePicker(
      initialEntryMode: TimePickerEntryMode.dial,
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_startTime.split(":")[0]),
        minute: int.parse(_startTime.split(":")[1].split(" ")[0]),
      ),
    );
  }
}
