import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/configs.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/profile_model.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/failures.dart';
import 'package:manager/core/utils/type_def.dart';
import 'package:manager/services/api.service.dart';

class ProfileService {
  final apiService = locator<ApiService>();

  /// Fetches the current user's profile data
  /// Returns ProfileModel with complete profile information including profileImage
  ResultFuture<ProfileModel> getProfile() async {
    try {
      final response = await apiService.get(url: ApiEndpoints.getProfile);

      if (response.statusCode == 200) {
        // Handle different response data types
        Map<String, dynamic> responseData;
        if (response.data is String) {
          responseData = jsonDecode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          responseData = response.data;
        } else {
          AppLogger.error('Invalid response format');
          return Left(Failure('Invalid response format'));
        }

        // Check if response has nested data structure
        ProfileModel profile;
        if (responseData['success'] == true && responseData['data'] != null) {
          profile = ProfileModel.fromJson(responseData['data']);
        } else {
          // Direct profile data parsing - handle user field as string ID
          Map<String, dynamic> profileData = Map<String, dynamic>.from(
            responseData,
          );
          if (profileData['user'] is String) {
            // If user is a string ID, create a minimal User object
            profileData['user'] = {
              '_id': profileData['user'],
              'fullName': '',
              'email': '',
            };
          }
          profile = ProfileModel.fromJson(profileData);
        }

        AppLogger.info('Profile fetched successfully: ${profile.toJson()}');
        return Right(profile);
      } else {
        AppLogger.error('Failed to fetch profile: ${response.statusMessage}');
        return Left(
          Failure('Failed to fetch profile: ${response.statusMessage}'),
        );
      }
    } catch (e) {
      AppLogger.error('Error fetching profile data: $e');
      if (e is DioException) {
        return Left(
          Failure(e.response?.data?['message'] ?? 'Failed to fetch profile'),
        );
      }
      return Left(Failure('Error fetching profile data: $e'));
    }
  }

  /// Updates the current user's profile data
  /// Returns updated ProfileModel
  ResultFuture<ProfileModel> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await apiService.put(
        url: ApiEndpoints.updateProfile,
        data: profileData,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData;
        if (response.data is String) {
          responseData = jsonDecode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          responseData = response.data;
        } else {
          AppLogger.error('Invalid response format');
          return Left(Failure('Invalid response format'));
        }

        ProfileModel profile;
        if (responseData['success'] == true && responseData['data'] != null) {
          profile = ProfileModel.fromJson(responseData['data']);
        } else {
          profile = ProfileModel.fromJson(responseData);
        }

        AppLogger.info('Profile updated successfully: ${profile.toJson()}');
        return Right(profile);
      } else {
        AppLogger.error('Failed to update profile: ${response.statusMessage}');
        return Left(
          Failure('Failed to update profile: ${response.statusMessage}'),
        );
      }
    } catch (e) {
      AppLogger.error('Error updating profile data: $e');
      if (e is DioException) {
        return Left(
          Failure(e.response?.data?['message'] ?? 'Failed to update profile'),
        );
      }
      return Left(Failure('Error updating profile data: $e'));
    }
  }
}
