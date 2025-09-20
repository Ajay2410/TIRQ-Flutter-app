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

    _socket!.onConnect((_) {
      print("✅ Connected: ${_socket!.id}");
    });

    _socket!.onDisconnect((_) {
      print("🔌 Disconnected");
    });

    _socket!.onError((err) {
      print("❌ Socket error: $err");
    });
  }

  /// Register user (with orgId/processorId)
  void registerUser(String orgOrProcessorId) {
    _socket?.emit("registerUser", {"userId": orgOrProcessorId});
  }

  /// Join room
  void joinRoom(String roomId) {
    _socket?.emit("JoinRoom", {"roomId": roomId});
  }

  /// Send message with optional attachments
  void sendMessage({
    required String roomId,
    required String content,
    List<Map<String, dynamic>> attachments = const [],
  }) {
    final payload = {
      "roomId": roomId,
      "content": content,
      "attachments": attachments, // each: {"type": "image|video|document", "url": "..."}
    };
    _socket?.emit("sendMessage", payload);
    print("📤 Sent message: $payload");
  }

  /// Listen for new messages
  void onNewMessage(Function(dynamic) handler) {
    _socket?.on("newMessage", handler);
  }

  /// Generic event listener
  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  /// Remove event listener
  void off(String event) {
    _socket?.off(event);
  }

  /// Dispose
  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
