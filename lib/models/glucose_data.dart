class GlucoseData {
  final int? id;
  final int userId;
  final int glucoseValue;
  final String deviceId;
  final DateTime timestamp;
  final bool isSynced;

  GlucoseData({
    this.id,
    required this.userId,
    required this.glucoseValue,
    required this.deviceId,
    required this.timestamp,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'glucoseValue': glucoseValue,
      'deviceId': deviceId,
      'timestamp': timestamp.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory GlucoseData.fromJson(Map<String, dynamic> json) {
    return GlucoseData(
      id: json['id'],
      userId: json['userId'],
      glucoseValue: json['glucoseValue'],
      deviceId: json['deviceId'],
      timestamp: DateTime.parse(json['timestamp']),
      isSynced: json['isSynced'] == 1,
    );
  }
} 