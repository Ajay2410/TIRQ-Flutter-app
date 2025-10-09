import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/profile_model.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/failures.dart';
import 'package:manager/core/utils/type_def.dart';
import 'package:manager/services/api.service.dart';

class ProfileService {
  final apiService = locator<ApiService>();

  // Global ProfileModel stored in memory
  ProfileModel? _globalProfileModel;

  // Track if profile has been initialized
  bool _isInitialized = false;

  // Getter for global profile model
  ProfileModel? get globalProfileModel => _globalProfileModel;

  // Check if profile is initialized
  bool get isInitialized => _isInitialized;

  // Initialize profile data - always fetch from API
  Future<void> initializeProfile() async {
    // Only initialize once
    if (_isInitialized) {
      AppLogger.info('Profile already initialized, skipping...');
      return;
    }

    // Always fetch from API (no local storage)
    await _fetchFromAPI();

    // Mark as initialized
    _isInitialized = true;
    AppLogger.info('Profile initialization completed');
  }

  // Fetch profile data from API
  Future<void> _fetchFromAPI() async {
    try {
      final response = await apiService.get(url: ApiEndpoints.getProfile);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData;
        if (response.data is String) {
          responseData = jsonDecode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          responseData = response.data;
        } else {
          AppLogger.error('Invalid response format');
          return;
        }

        // Parse profile data
        ProfileModel profile;
        if (responseData['profile'] != null) {
          // The response has both 'profile' and 'qrCode' fields
          profile = ProfileModel.fromJson(responseData);
        } else if (responseData['success'] == true &&
            responseData['data'] != null) {
          profile = ProfileModel.fromJson(responseData['data']);
        } else {
          profile = ProfileModel.fromJson(responseData);
        }

        _globalProfileModel = profile;
        AppLogger.info('Profile fetched from API');
      } else {
        AppLogger.error('Failed to fetch profile: ${response.statusMessage}');
      }
    } catch (e) {
      AppLogger.error('Error fetching profile from API: $e');
    }
  }

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
        } else if (responseData['profile'] != null) {
          // Handle the nested profile structure from API response
          // The response has both 'profile' and 'qrCode' fields
          profile = ProfileModel.fromJson(responseData);
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

  // Update profile data
  Future<void> updateProfileData(Map<String, dynamic> updateData) async {
    try {
      AppLogger.info('ProfileService: Sending update data to API: $updateData');

      final response = await apiService.put(
        url: ApiEndpoints.updateProfile,
        data: updateData,
      );

      AppLogger.info(
        'ProfileService: API response status: ${response.statusCode}',
      );
      AppLogger.info('ProfileService: API response data: ${response.data}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData;
        if (response.data is String) {
          responseData = jsonDecode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          responseData = response.data;
        } else {
          AppLogger.error('Invalid response format');
          return;
        }

        AppLogger.info('ProfileService: Parsed response data: $responseData');

        // Update global profile model with new data
        if (_globalProfileModel != null) {
          // Handle the case where user is a string ID instead of nested object
          Map<String, dynamic> profileData = Map.from(responseData);

          // If user is a string ID, preserve the existing user object
          if (responseData['user'] is String) {
            profileData['user'] =
                _globalProfileModel!.profile?.user?.toJson() ?? {};
          }

          final updatedProfile = ProfileModel.fromJson(profileData);
          _globalProfileModel = updatedProfile;
          AppLogger.info('ProfileService: Profile updated');
        }
      } else {
        AppLogger.error('Failed to update profile: ${response.statusMessage}');
      }
    } catch (e) {
      AppLogger.error('Error updating profile: $e');
    }
  }

  // Refresh profile data from API
  Future<void> refreshProfile() async {
    try {
      AppLogger.info('ProfileService: Refreshing profile data from API...');

      final response = await apiService.get(url: ApiEndpoints.getProfile);

      AppLogger.info(
        'ProfileService: API response status: ${response.statusCode}',
      );
      AppLogger.info('ProfileService: API response data: ${response.data}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData;
        if (response.data is String) {
          responseData = jsonDecode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          responseData = response.data;
        } else {
          AppLogger.error('ProfileService: Invalid response format');
          return;
        }

        // Parse the profile data from the response
        ProfileModel profile;
        if (responseData['profile'] != null) {
          // The response has both 'profile' and 'qrCode' fields
          profile = ProfileModel.fromJson(responseData);
        } else if (responseData['success'] == true &&
            responseData['data'] != null) {
          profile = ProfileModel.fromJson(responseData['data']);
        } else {
          profile = ProfileModel.fromJson(responseData);
        }

        // Update global profile model
        _globalProfileModel = profile;
        AppLogger.info('ProfileService: Profile refreshed successfully');
      } else {
        AppLogger.error(
          'ProfileService: Failed to refresh profile: ${response.statusMessage}',
        );
      }
    } catch (e) {
      AppLogger.error('ProfileService: Error refreshing profile: $e');
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

  // Clear profile data (for logout)
  Future<void> clearProfileData() async {
    try {
      _globalProfileModel = null;
      _isInitialized = false; // Reset initialization flag
      AppLogger.info('Profile data cleared');
    } catch (e) {
      AppLogger.error('Error clearing profile data: $e');
    }
  }
}
