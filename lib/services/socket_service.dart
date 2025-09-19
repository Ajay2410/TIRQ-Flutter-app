import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;

  /// Initialize socket connection
  void initializeSocket({
    required String serverUrl,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? extraHeaders,
  }) {
    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery(queryParams ?? {})
          .setExtraHeaders(extraHeaders ?? {})
          .enableAutoConnect()
          .build(),
    );

    // Listen for connection
    _socket!.onConnect((_) {
      print("connected ${_socket!.id}");

      // Register user after connection
      if (queryParams != null && queryParams['userId'] != null) {
        _socket!.emit("registerUser", {"userId": queryParams['userId']});
      }
    });
  }

  /// Clean up resources
  void dispose() {
    if (_socket != null) {
      _socket!.dispose();
      _socket = null;
    }
  }
}
