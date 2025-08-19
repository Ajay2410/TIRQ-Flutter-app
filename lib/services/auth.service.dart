import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/type_def.dart';
import 'package:manager/services/api.service.dart';
import 'package:stacked_services/stacked_services.dart';

import '../core/models/hive/user/user.dart';
import '../core/utils/failures.dart';
import '../routes/routes.dart';

class AuthService {
  final apiService = locator<ApiService>();
  final _navigationService = locator<NavigationService>();

  ResultFuture<String> registerOrganization({
    required String name,
    required String type,
    required String phone,
    required String email,
    required String password,
    required String countryCode,      // Separate parameter for country code
    String? language,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.registerOrganization,
        data: {
          'name': name,
          'organizationType': type,
          'phone': phone,
          'email': email,
          'password': password,
          'countryCode': countryCode,
          'language': language,
        },
      );

      if (response.data['success'] == true) {
        return Right(response.data['organizationId']);
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
    return Left(Failure('Failed to register organization'));
  }

  ResultFuture<String> registerEmployee({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.registerEmployee,
        data: {
          'fullName': name,
          'phone': phone,
          'email': email,
          'password': password,
        },
      );

      if (response.data['success'] == true) {
        return Right(response.data['employeeId']);
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
    return Left(Failure('Failed to register employee'));
  }

  ResultFuture<User> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.verifyEmail,
        data: {'email': email, 'otp': otp},
      );

      if (response.data['success'] == true) {
        return Right(User.fromJson(response.data['user']));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to verify email'));
  }

  ResultFuture<User> verifyPhone({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.verifyPhone,
        data: {'phone': phone, 'otp': otp},
      );

      if (response.data['success'] == true) {
        return Right(User.fromJson(response.data['user']));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to verify email'));
  }

  ResultFuture<bool> forgotPassword({required String email}) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      if (response.data['success'] == true) {
        return Right(true);
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to verify email'));
  }

  ResultFuture<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.resetPassword, // You need to add this endpoint
        data: {'email': email, 'otp': otp, 'newPassword': newPassword},
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
    return Left(Failure('Failed to reset password'));
  }

  ResultFuture<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      if (response.data['success'] == true) {
        return Right(User.fromJson(response.data['user']));
      }

    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to login user'));
  }

  ResultFuture<User> googleLogin({
    required String email,
    String ? token,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.googleLogin,
        data: {'email': email, 'idToken': token ?? ""},
      );

      if (response.data['success'] == true) {
        return Right(User.fromJson(response.data['user']));
      }

    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to login user'));
  }

  ResultFuture<User> facebookLogin({
    required String email,
    String ? token,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.googleLogin,
        data: {'email': email, 'idToken': token ?? ""},
      );

      if (response.data['success'] == true) {
        return Right(User.fromJson(response.data['user']));
      }

    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to login user'));
  }


  ResultFuture<User> otpLogin({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.otpLogin,
        data: {'email': email, 'otp': otp},
      );

      if (response.data['success'] == true) {
        return Right(User.fromJson(response.data['user']));
      }

    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to login user'));
  }

  Future<Object> sendOtp({
    required String email
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.sendOtp,
        data: {'email': email},
      );

      if (response.data['success'] == true) {
        return true;
      }

    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('User not found'));
  }

  ResultFuture<bool> sendPasswordResetOtp({
    required String email,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.forgotPassword,
        data: {'email': email},
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
    return Left(Failure('Failed to send password reset OTP'));
  }



  ResultFuture<bool> updateFcmToken({
    required String token,
    required String? oldToken,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.updateFcmToken,
        data: {'oldToken': oldToken??'', 'newToken': token,},
      );

      if (response.data['success'] == true) {
        return Right(true);
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        if(e.response?.statusCode == 401){
          await clearHive();
          await _navigationService.clearStackAndShow(Routes.login);
        }
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to login user'));
  }

  ResultFuture<bool> logout(String? fcmToken) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.logout,
        data: {'fcmToken': fcmToken ?? ''},
      );

      if (response.data['success'] == true) {
        await clearHive();
        await _navigationService.clearStackAndShow(Routes.login);
        return Right(true);
      } else {
        return Left(Failure(response.data['message']));
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        // Still clear local data and redirect to login on error
        await clearHive();
        await _navigationService.clearStackAndShow(Routes.login);
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
    }
    return Left(Failure('Failed to logout user'));
  }

  ResultFuture<bool> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      // You might need a separate endpoint for this or use the existing otpLogin
      final response = await apiService.post(
        url: ApiEndpoints.otpLogin, // Temporary - you might need a different endpoint
        data: {'email': email, 'otp': otp},
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
    return Left(Failure('Failed to verify password reset OTP'));
  }







}
