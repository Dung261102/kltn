import 'package:get/get.dart';

typedef GlucoseRecord = ({DateTime time, int value});

class GlucoseController extends GetxController {
  RxList<GlucoseRecord> glucoseHistory = <GlucoseRecord>[].obs;

  void setHistory(List<GlucoseRecord> list) {
    glucoseHistory.assignAll(list);
  }

  void addRecord(GlucoseRecord record) {
    glucoseHistory.add(record);
  }

  void clearHistory() {
    glucoseHistory.clear();
  }
} 