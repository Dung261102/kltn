
import 'package:socket_io_client_flutter/socket_io_client_flutter.dart' as IO;
import 'package:socket_io_common/src/util/event_emitter.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket _socket;
  bool _isConnected = false;

  // Thay đổi URL backend cho phù hợp
  final String _baseUrl = 'http://localhost:3000';

  // Kết nối tới Socket.IO server
  void connect({Function? onConnect, Function? onDisconnect, Function(dynamic)? onError}) {
    if (_isConnected) return;
    _socket = IO.io(_baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.connect();

    _socket.onConnect((_) {
      _isConnected = true;
      if (onConnect != null) onConnect();
      print('Socket.IO: Đã kết nối');
    });

    _socket.onDisconnect((_) {
      _isConnected = false;
      if (onDisconnect != null) onDisconnect();
      print('Socket.IO: Ngắt kết nối');
    });

    _socket.onError((data) {
      if (onError != null) onError(data);
      print('Socket.IO: Lỗi - $data');
    });
  }

  // Ngắt kết nối
  void disconnect() {
    if (_isConnected) {
      _socket.disconnect();
      _isConnected = false;
      print('Socket.IO: Đã ngắt kết nối');
    }
  }

  // Gửi dữ liệu (emit event)
  void emit(String event, dynamic data) {
    if (_isConnected) {
      _socket.emit(event, data);
      print('Socket.IO: Đã gửi $event với data: $data');
    }
  }

  // Lắng nghe sự kiện từ server
  void on(String event, Function(dynamic) handler) {
    _socket.on(event, handler);
  }

  // Hủy lắng nghe sự kiện
  void off(String event, [Function? handler]) {
    _socket.off(event, handler as EventHandler?);
  }

  // Kiểm tra trạng thái kết nối
  bool get isConnected => _isConnected;

  // Lấy socket gốc nếu cần dùng trực tiếp
  IO.Socket get rawSocket => _socket;
}