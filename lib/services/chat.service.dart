import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manager/features/chat/model/chat_message_model.dart';

import '../api_endpoints.dart';
import '../core/locator.dart';
import '../core/models/chat_list_model.dart';
import '../core/utils/app_logger.dart';
import '../core/utils/failures.dart';
import '../core/utils/type_def.dart';
import 'api.service.dart';

class ChatService {
  final _apiService = locator<ApiService>();

  bool _isRefreshing = false;

  bool get isRefreshing => _isRefreshing;

  // Stream controller for external refresh triggers
  final _refreshController = StreamController<bool>.broadcast();

  Stream<bool> get refreshStream => _refreshController.stream;

  void triggerRefresh() {
    if (!_isRefreshing) {
      _refreshController.add(true);
      AppLogger.highlight("Refresh triggered from external source");
    } else {
      AppLogger.warning("Refresh already in progress, ignoring trigger");
    }
  }

  // Reset refresh flag manually if needed
  void resetRefreshFlag() {
    _isRefreshing = false;
  }

  ResultFuture<bool> sendMessage({
    required String roomId,
    required Map<String, dynamic> message,
  }) async {
    try {
      final response = await _apiService.post(
        url: '${ApiEndpoints.sendMessage}/$roomId',
        data: {'message': message},
      );

      if (response.data['success'] == true) {
        return Right(true);
      } else {
        return Left(Failure(response.data['message']));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to send message'));
  }

  ResultFuture<List<ChatMessageModel>> getAllChatMessages({
    required String roomId,
  }) async {
    try {
      final response = await _apiService.get(
        url: '${ApiEndpoints.getAllChatMessages}/$roomId',
      );

      if (response.statusCode == 200) {
        List<ChatMessageModel> messageList =
            (response.data as List)
                .map((e) => ChatMessageModel.fromJson(e))
                .toList();
        return Right(messageList);
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Failed to get messages'),
        );
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
      return Left(Failure('Failed to get messages: $e'));
    }
  }

  /// Get paginated chat messages
  ResultFuture<Map<String, dynamic>> getPaginatedChatMessages({
    required String roomId,
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _apiService.get(
        url: '${ApiEndpoints.getAllChatMessages}/$roomId',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        return Right(response.data);
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Failed to get messages'),
        );
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
      return Left(Failure('Failed to get messages: $e'));
    }
  }

  ResultFuture<List<ChatListModel>> getAllChats() async {
    try {
      final response = await _apiService.get(url: ApiEndpoints.getAllChats);

      if (response.statusCode == 200) {
        final chatList =
            (response.data as List)
                .map((e) => ChatListModel.fromJson(e))
                .toList();
        return Right(chatList);
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Failed to get all chats'),
        );
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
      return Left(Failure('Failed to get all chats: $e'));
    }
  }

  /// Upload files for chat
  ResultFuture<Map<String, dynamic>> uploadChatFiles(
    List<String> filePaths,
  ) async {
    try {
      final List<MultipartFile> files = [];

      for (String filePath in filePaths) {
        files.add(await MultipartFile.fromFile(filePath));
      }

      final formData = FormData.fromMap({'files': files});

      final response = await _apiService.post(
        url: ApiEndpoints.uploadChatFile,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 201) {
        return Right(response.data);
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Failed to upload files'),
        );
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
      return Left(Failure('Failed to upload files: $e'));
    }
  }
}
