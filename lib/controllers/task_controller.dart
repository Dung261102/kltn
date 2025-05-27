import 'package:get/get.dart';
import 'package:glucose_real_time/db/db_helper.dart';
import '../models/task.dart';

class TaskController extends GetxController {
  @override
  void onReady() {
    super.onReady();
  }

  var taskList = <Task>[].obs;

  // Thêm task mới
  Future<int> addTask({Task? task}) async {
    return await DBHelper.insert(task);
  }

  // Lấy toàn bộ task từ DB
  void getTask() async {
    List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
  }

  // Xoá một task cụ thể
  void delete(Task task) {
    DBHelper.delete(task);
    getTask();
  }

  // Đánh dấu task đã hoàn thành
  void markTaskCompleted(int id) async {
    await DBHelper.update(id);
    getTask();
  }

  // ✅ Xoá toàn bộ task
  // void deleteAllTasks() async {
  //   await DBHelper.deleteAll(); // gọi đến DBHelper để xoá toàn bộ
  //   await DBHelper.resetTaskId(); // reset lại ID tự động
  //   getTask(); // cập nhật lại danh sách
  // }
}
