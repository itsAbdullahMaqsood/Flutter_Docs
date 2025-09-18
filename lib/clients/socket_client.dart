import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  IO.Socket? socket;
  static SocketClient? _instance;
  SocketClient._internal() {
    socket = IO.io("http://192.168.100.8:3002", <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket!.connect();

  socket!.onConnect((_) {
    print('Connected to socket server');
  });

  socket!.on('changes', (data) {
    print('Received changes: $data');
  });

  socket!.onDisconnect((_) {
    print('Disconnected from socket server');
  });
}

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }
}


