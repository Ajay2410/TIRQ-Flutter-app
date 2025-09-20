import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  SocketService._internal();

  IO.Socket? _socket;

  /// Initialize socket connection
  void initializeSocket({required String serverUrl, Map<String, dynamic>? queryParams, Map<String, dynamic>? extraHeaders}) {
    print("🔌 Initializing socket to: $serverUrl");
    print("📋 Query params: $queryParams");
    print("🔑 Headers: $extraHeaders");

    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder().setTransports(['websocket']).setQuery(queryParams ?? {}).setExtraHeaders(extraHeaders ?? {}).enableAutoConnect().build(),
    );

    _socket!.onConnect((_) {
      print("✅ Socket connected with ID: ${_socket!.id}");
    });

    _socket!.onDisconnect((_) {
      print("🔌 Socket disconnected");
    });

    _socket!.onError((err) {
      print("❌ Socket error: $err");
    });

    _socket!.onConnectError((err) {
      print("❌ Socket connection error: $err");
    });
  }

  /// Register user (with orgId/processorId)
  void registerUser(String orgOrProcessorId) {
    print("👤 Registering user: $orgOrProcessorId");
    _socket?.emit("registerUser", {"userId": orgOrProcessorId});
    print("👤 User registration emitted");
  }

  /// Join room
  void joinRoom(String roomId) {
    print("🏠 Joining room: $roomId");
    _socket?.emit("joinRoom", {"roomId": roomId});
    print("🏠 Room join emitted");
  }

  /// Send message with optional attachments
  void sendMessage({required String roomId, required String content, List<Map<String, dynamic>> attachments = const []}) {
    final payload = {
      "roomId": roomId,
      "content": content,
      "attachments": attachments, // each: {"type": "image|video|document", "url": "..."}
    };

    print("📤 Sending message with payload: $payload");
    print("🔌 Socket connected: ${_socket?.connected}");
    print("🆔 Socket ID: ${_socket?.id}");

    _socket?.emit("sendMessage", payload);
    print("📤 Message emitted successfully");
  }

  /// Listen for new messages
  void onNewMessage(Function(dynamic) handler) {
    print("🔌 Setting up newMessage listener");
    _socket?.on("newMessage", (data) {
      print("📨 New message received: $data");
      handler(data); // Call the handler function with the received data
    });
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
