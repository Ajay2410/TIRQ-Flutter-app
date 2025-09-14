import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../api_endpoints.dart';
import '../core/locator.dart';
import '../core/utils/app_logger.dart';
import '../core/utils/failures.dart';
import '../core/utils/type_def.dart';
import '../features/Messages/chat/chat.view.dart';
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

  ResultFuture<ChatViewAttributes> getChatViewAttributesForTicket({
    required String ticketId,
  }) async {
    // try {
    final response = await _apiService.post(
      url: ApiEndpoints.getChatId,
      data: {'ticketId': ticketId},
    );

    if (response.data['success'] == true) {
      return Right(ChatViewAttributes.fromJson(response.data['data']));
    } else {
      return Left(Failure(response.data['message']));
    }
    // } catch (e) {
    //   if (e is DioException) {
    //     AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
    //     return Left(
    //       Failure(e.response?.data?['message'] ?? 'Something went wrong'),
    //     );
    //   }
    // }
    return Left(Failure('Failed to get machines'));
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

  ResultFuture<List<ChatViewAttributes>> getArchivedChatRooms() async {
    try {
      final response = await _apiService.get(url: ApiEndpoints.archiveChatRoom);
      if (response.statusCode == 200) {
        // Return the actual data list instead of just true
        final chatRooms =
            (response.data as List)
                .map((e) => ChatViewAttributes.fromJson(e))
                .toList();
        return Right(chatRooms);
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Failed to get chat rooms'),
        );
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
      return Left(Failure('Failed to get chat rooms: $e'));
    }
  }

  ResultFuture<List<ChatViewAttributes>> getChatRooms() async {
    // try {
    //   final response = await _apiService.get(url: ApiEndpoints.chatRooms);

    //   if (response.statusCode == 200) {
    //     // Return the actual data list instead of just true
    //     final chatRooms = (response.data as List).map((e) => ChatViewAttributes.fromJson(e)).toList();
    //     return Right(chatRooms);
    //   } else {
    //     return Left(Failure(response.data['message'] ?? 'Failed to get chat rooms'));
    //   }
    // } catch (e) {
    //   if (e is DioException) {
    //     AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
    //     return Left(Failure(e.response?.data?['message'] ?? 'Something went wrong'));
    //   }
    //   return Left(Failure('Failed to get chat rooms: $e'));
    // }
    return Left(Failure('Failed to get chat rooms'));
  }

  ResultFuture<ChatViewAttributes> createIndividualChatRoom({
    required List<String> employeeIds,
  }) async {
    try {
      final response = await _apiService.post(
        url: ApiEndpoints.createIndividualChatRoom,
        data: {'employeeIds': employeeIds},
      );

      if (response.data['success'] == true) {
        return Right(ChatViewAttributes.fromJson(response.data['data']));
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
      return Left(Failure('Failed to create individual chat room: $e'));
    }
  }

  ResultFuture<List<ChatViewAttributes>> getExternalChatRooms() async {
    // try {
    //   final response = await _apiService.get(url: ApiEndpoints.externalChatRooms);

    // if (response.data['success'] == true) {
    //   final chatRooms = (response.data['data'] as List).map((e) => ChatViewAttributes.fromJson(e)).toList();
    //   return Right(chatRooms);
    // } else {
    //   return Left(Failure(response.data['message'] ?? 'Failed to get external chat rooms'));
    // }
    // } catch (e) {
    //   if (e is DioException) {
    //     AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
    //     return Left(Failure(e.response?.data?['message'] ?? 'Something went wrong'));
    //   }
    //   return Left(Failure('Failed to get external chat rooms: $e'));
    // }
    return Left(Failure('Failed to get external chat rooms'));
  }
}
