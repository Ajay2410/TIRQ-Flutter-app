import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/configs.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/services/user.service.dart';

import '../core/locator.dart';
import '../core/utils/app_logger.dart';
import '../core/utils/helpers/helpers.dart';
import '../core/models/api_response.dart';
import '../core/utils/failures.dart';
import '../core/utils/type_def.dart';

class ApiService {
  late Dio _dio;

  final _config = locator<Configurations>();
  final String _deviceId = '';
  String _appVersion = '';
  final String _os = Platform.operatingSystem;

  Future<String> getAppVersion() async {
    _appVersion = await getCurrentAppVersion();
    return _appVersion;
  }

  Future<String> getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor ?? "";
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return ((await const AndroidId().getId()) ?? androidDeviceInfo.id);
    }
    return "";
  }

  ApiService() {
    getDeviceId();
    getAppVersion();
    _dio = Dio(
      BaseOptions(
        baseUrl: _config.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 90),
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers.addAll({
            'Authorization': 'Bearer ${getUser().token}',
            'language': locator<UserService>().selectedLanguage,
            'device-id': _deviceId,
            // 'Accept-Language':
            //     options.headers['Accept-Language'] ?? getCurrentLocale(),
            'app-version': _appVersion,
            'os': _os,
            // 'user-id': ,
          });

          if (kDebugMode) {
            logRequest(options);
          }
          var connectivityResult = await Connectivity().checkConnectivity();
          if (connectivityResult.contains(ConnectivityResult.none)) {
            // Show snackBar for no internet connection
            Fluttertoast.showToast(
              msg: "No internet connection",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
            return handler.reject(
              DioException(
                requestOptions: options,
                error: "No internet connection",
              ),
            );
          }

          return handler.next(options);
        },
        onResponse: (response, handler) async {
          logResponse(response);
          if (response.data.runtimeType == String) {
            return handler.next(response);
          }
          try {
            // final deeplink = Result.fromJson(response.data).deeplink;
            // if (deeplink != null) {
            //   final uri = Uri.tryParse(deeplink);
            //   final willWait = (uri?.queryParameters['await'] ?? false) == true;
            //   if (willWait) {
            //     await DeeplinkNavigator.handleNavigation(
            //       url: Uri.tryParse(deeplink),
            //     );
            //   } else {
            //     DeeplinkNavigator.handleNavigation(url: Uri.tryParse(deeplink));
            //   }
            // }
          } catch (e) {
            AppLogger.error(e.toString());
          }
          return handler.next(response);
        },
        onError: (DioException err, handler) async {
          logError(err);
          return handler.next(err);
        },
      ),
    );
  }

  /// Enhanced GET method with error handling and toast support
  Future<Response> get({
    required String url,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    String? baseUrl,
    Options? options,
    bool showToast = true,
  }) async {
    try {
      var response = await _dio.get(
        "${baseUrl ?? _config.baseUrl}$url",
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      _handleApiError(e, showToast: showToast);
      rethrow;
    } on Exception catch (e) {
      AppLogger.error("GET request exception: $e");
      if (showToast) {
        _showErrorToast("Network error occurred", 0);
      }
      rethrow;
    }
  }

  /// Enhanced GET method that returns ApiResponse with automatic error handling
  Future<ApiResponse<T>> getWithErrorHandling<T>({
    required String url,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    String? baseUrl,
    Options? options,
    T Function(dynamic)? fromJsonT,
    bool showToast = true,
  }) async {
    try {
      var response = await _dio.get(
        "${baseUrl ?? _config.baseUrl}$url",
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
      return _processResponse<T>(response, fromJsonT, showToast: showToast);
    } on DioException catch (e) {
      _handleApiError(e, showToast: showToast);
      return ApiResponse<T>(
        success: false,
        message: _extractErrorMessage(
          e.response?.data,
          e.response?.statusCode ?? 0,
        ),
        statusCode: e.response?.statusCode ?? 0,
      );
    } on Exception catch (e) {
      AppLogger.error("GET request exception: $e");
      final errorMessage = "Network error occurred";
      if (showToast) {
        _showErrorToast(errorMessage, 0);
      }
      return ApiResponse<T>(
        success: false,
        message: errorMessage,
        statusCode: 0,
      );
    }
  }

  /// Enhanced POST method with error handling and toast support
  Future<Response> post({
    required String url,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    CancelToken? cancelToken,
    Options? options,
    bool showToast = true,
  }) async {
    try {
      var response = await _dio.post(
        "${_config.baseUrl}$url",
        queryParameters: queryParameters,
        data: data,
        cancelToken: cancelToken,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      _handleApiError(e, showToast: showToast);
      rethrow;
    } on Exception catch (e) {
      AppLogger.error("POST request exception: $e");
      if (showToast) {
        _showErrorToast("Network error occurred", 0);
      }
      rethrow;
    }
  }

  /// Enhanced POST method that returns ApiResponse with automatic error handling
  Future<ApiResponse<T>> postWithErrorHandling<T>({
    required String url,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    CancelToken? cancelToken,
    Options? options,
    T Function(dynamic)? fromJsonT,
    bool showToast = true,
  }) async {
    try {
      var response = await _dio.post(
        "${_config.baseUrl}$url",
        queryParameters: queryParameters,
        data: data,
        cancelToken: cancelToken,
        options: options,
      );
      return _processResponse<T>(response, fromJsonT, showToast: showToast);
    } on DioException catch (e) {
      _handleApiError(e, showToast: showToast);
      return ApiResponse<T>(
        success: false,
        message: _extractErrorMessage(
          e.response?.data,
          e.response?.statusCode ?? 0,
        ),
        statusCode: e.response?.statusCode ?? 0,
      );
    } on Exception catch (e) {
      AppLogger.error("POST request exception: $e");
      final errorMessage = "Network error occurred";
      if (showToast) {
        _showErrorToast(errorMessage, 0);
      }
      return ApiResponse<T>(
        success: false,
        message: errorMessage,
        statusCode: 0,
      );
    }
  }

  /// Enhanced PUT method with error handling and toast support
  Future<Response> put({
    required String url,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    CancelToken? cancelToken,
    Options? options,
    bool showToast = true,
  }) async {
    try {
      var response = await _dio.put(
        "${_config.baseUrl}$url",
        queryParameters: queryParameters,
        data: data,
        cancelToken: cancelToken,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      _handleApiError(e, showToast: showToast);
      rethrow;
    } on Exception catch (e) {
      AppLogger.error("PUT request exception: $e");
      if (showToast) {
        _showErrorToast("Network error occurred", 0);
      }
      rethrow;
    }
  }

  /// Enhanced PUT method that returns ApiResponse with automatic error handling
  Future<ApiResponse<T>> putWithErrorHandling<T>({
    required String url,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    CancelToken? cancelToken,
    Options? options,
    T Function(dynamic)? fromJsonT,
    bool showToast = true,
  }) async {
    try {
      var response = await _dio.put(
        "${_config.baseUrl}$url",
        queryParameters: queryParameters,
        data: data,
        cancelToken: cancelToken,
        options: options,
      );
      return _processResponse<T>(response, fromJsonT, showToast: showToast);
    } on DioException catch (e) {
      _handleApiError(e, showToast: showToast);
      return ApiResponse<T>(
        success: false,
        message: _extractErrorMessage(
          e.response?.data,
          e.response?.statusCode ?? 0,
        ),
        statusCode: e.response?.statusCode ?? 0,
      );
    } on Exception catch (e) {
      AppLogger.error("PUT request exception: $e");
      final errorMessage = "Network error occurred";
      if (showToast) {
        _showErrorToast(errorMessage, 0);
      }
      return ApiResponse<T>(
        success: false,
        message: errorMessage,
        statusCode: 0,
      );
    }
  }

  /// Enhanced DELETE method with error handling and toast support
  Future<Response> delete({
    required String url,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    CancelToken? cancelToken,
    Options? options,
    bool showToast = true,
  }) async {
    try {
      var response = await _dio.delete(
        "${_config.baseUrl}$url",
        queryParameters: queryParameters,
        data: data,
        cancelToken: cancelToken,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      _handleApiError(e, showToast: showToast);
      rethrow;
    } on Exception catch (e) {
      AppLogger.error("DELETE request exception: $e");
      if (showToast) {
        _showErrorToast("Network error occurred", 0);
      }
      rethrow;
    }
  }

  /// Enhanced DELETE method that returns ApiResponse with automatic error handling
  Future<ApiResponse<T>> deleteWithErrorHandling<T>({
    required String url,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    CancelToken? cancelToken,
    Options? options,
    T Function(dynamic)? fromJsonT,
    bool showToast = true,
  }) async {
    try {
      var response = await _dio.delete(
        "${_config.baseUrl}$url",
        queryParameters: queryParameters,
        data: data,
        cancelToken: cancelToken,
        options: options,
      );
      return _processResponse<T>(response, fromJsonT, showToast: showToast);
    } on DioException catch (e) {
      _handleApiError(e, showToast: showToast);
      return ApiResponse<T>(
        success: false,
        message: _extractErrorMessage(
          e.response?.data,
          e.response?.statusCode ?? 0,
        ),
        statusCode: e.response?.statusCode ?? 0,
      );
    } on Exception catch (e) {
      AppLogger.error("DELETE request exception: $e");
      final errorMessage = "Network error occurred";
      if (showToast) {
        _showErrorToast(errorMessage, 0);
      }
      return ApiResponse<T>(
        success: false,
        message: errorMessage,
        statusCode: 0,
      );
    }
  }

  /// Enhanced error handling with status code mapping and toast support
  void _handleApiError(DioException e, {bool showToast = true}) {
    try {
      final statusCode = e.response?.statusCode ?? 0;
      final responseData = e.response?.data;

      String errorMessage = _extractErrorMessage(responseData, statusCode);

      AppLogger.error("API Error: $errorMessage (Status: $statusCode)");

      if (showToast) {
        _showErrorToast(errorMessage, statusCode);
      }
    } catch (ex) {
      AppLogger.error("Error handling API exception: $ex");
      if (showToast) {
        _showErrorToast("An unexpected error occurred", 0);
      }
    }
  }

  /// Extract error message from response data
  String _extractErrorMessage(dynamic responseData, int statusCode) {
    if (responseData is Map<String, dynamic>) {
      // Try to get message from common error response formats
      if (responseData.containsKey('message') &&
          responseData['message'] != null) {
        return responseData['message'].toString();
      }

      if (responseData.containsKey('error') && responseData['error'] != null) {
        return responseData['error'].toString();
      }

      if (responseData.containsKey('errors') &&
          responseData['errors'] != null) {
        final errors = responseData['errors'];
        if (errors is Map && errors.isNotEmpty) {
          return errors.values.first.toString();
        }
        if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        }
      }
    }

    return _getDefaultErrorMessage(statusCode);
  }

  /// Get default error message based on status code
  String _getDefaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad Request - Invalid data provided';
      case 401:
        return 'Unauthorized - Please login again';
      case 403:
        return 'Forbidden - You do not have permission';
      case 404:
        return 'Not Found - Resource not available';
      case 422:
        return 'Validation Error - Please check your input';
      case 429:
        return 'Too Many Requests - Please try again later';
      case 500:
        return 'Internal Server Error - Please try again later';
      case 502:
        return 'Bad Gateway - Service temporarily unavailable';
      case 503:
        return 'Service Unavailable - Please try again later';
      case 504:
        return 'Gateway Timeout - Request timed out';
      default:
        return 'Network error occurred';
    }
  }

  /// Show error toast with appropriate styling
  void _showErrorToast(String message, int statusCode) {
    Color backgroundColor;
    Color textColor = Colors.white;

    if (statusCode >= 400 && statusCode < 500) {
      backgroundColor = Colors.orange; // Client errors - orange
    } else if (statusCode >= 500) {
      backgroundColor = Colors.red; // Server errors - red
    } else {
      backgroundColor = Colors.grey; // Other errors - grey
    }

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 14.0,
    );
  }

  /// Process API response and handle errors
  ApiResponse<T> _processResponse<T>(
    Response response,
    T Function(dynamic)? fromJsonT, {
    bool showToast = true,
  }) {
    try {
      final statusCode = response.statusCode ?? 0;
      final responseData = response.data;

      // Check if response is successful
      if (statusCode >= 200 && statusCode < 300) {
        // Handle different response data types
        if (responseData is Map<String, dynamic>) {
          // Standard JSON response
          return ApiResponse<T>(
            success: true,
            data:
                fromJsonT != null && responseData['data'] != null
                    ? fromJsonT(responseData['data'])
                    : responseData['data'],
            message: responseData['message'],
            statusCode: statusCode,
            errors: responseData['errors'],
          );
        } else if (responseData is String) {
          // String response (e.g., "success", "error message")
          try {
            final jsonData = jsonDecode(responseData);
            if (jsonData is Map<String, dynamic>) {
              return ApiResponse<T>(
                success: true,
                data:
                    fromJsonT != null && jsonData['data'] != null
                        ? fromJsonT(jsonData['data'])
                        : jsonData['data'],
                message: jsonData['message'],
                statusCode: statusCode,
                errors: jsonData['errors'],
              );
            } else {
              // If JSON but not a Map, treat as raw data
              return ApiResponse.fromRawData(
                responseData,
                statusCode,
                fromJsonT,
              );
            }
          } catch (_) {
            // If not JSON, treat as raw string
            return ApiResponse.fromRawData(responseData, statusCode, fromJsonT);
          }
        } else {
          // Primitive types (int, double, bool, List, etc.)
          return ApiResponse.fromRawData(responseData, statusCode, fromJsonT);
        }
      } else {
        // Handle error responses
        String errorMessage = _extractErrorMessage(responseData, statusCode);

        if (showToast) {
          _showErrorToast(errorMessage, statusCode);
        }

        return ApiResponse<T>(
          success: false,
          message: errorMessage,
          statusCode: statusCode,
          errors:
              responseData is Map<String, dynamic>
                  ? responseData['errors']
                  : null,
        );
      }
    } catch (e) {
      AppLogger.error("Error processing response: $e");
      final errorMessage = "Failed to process response";

      if (showToast) {
        _showErrorToast(errorMessage, 0);
      }

      return ApiResponse<T>(
        success: false,
        message: errorMessage,
        statusCode: 0,
      );
    }
  }

  /// Convert ApiResponse to EitherResult for use with existing services
  EitherResult<T> apiResponseToEither<T>(ApiResponse<T> response) {
    if (response.isSuccess && response.data != null) {
      return Right(response.data as T);
    } else {
      return Left(Failure(response.errorMessage));
    }
  }

  /// Helper method to get data from ApiResponse with null safety
  T? getDataFromResponse<T>(ApiResponse<T> response) {
    return response.isSuccess ? response.data : null;
  }

  /// Helper method to check if response is successful
  bool isResponseSuccessful<T>(ApiResponse<T> response) {
    return response.isSuccess;
  }

  /// Helper method to get error message from ApiResponse
  String getErrorMessageFromResponse<T>(ApiResponse<T> response) {
    return response.errorMessage;
  }

  void displayDioExceptionSnackBar(DioException e) {
    try {
      // if status code is 500, then show a generic message
      if (e.response?.statusCode == 500) {
        return;
      }
    } catch (e) {
      AppLogger.error(e);
    }
  }

  final _encoder = const JsonEncoder.withIndent('  ');

  Map convertFormDataToObject(FormData formData) {
    Map<String, dynamic> dataMap = {'fields': {}, 'files': {}};

    for (var field in formData.fields) {
      dataMap['fields'][field.key] = field.value;
    }

    for (var file in formData.files) {
      dataMap['files'][file.key] = {
        'filename': file.value.filename,
        'contentType': file.value.contentType.toString(),
      };
    }

    return dataMap;
  }

  String requestDetails(RequestOptions options) {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln('URI: ${options.uri}');

    buffer.writeln('Method: ${options.method}');

    if (options.headers.isNotEmpty) {
      buffer.writeln('Headers:');
      options.headers.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    } else {
      buffer.writeln('Headers: None');
    }

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('Query Parameters:');
      options.queryParameters.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    } else {
      buffer.writeln('Query Parameters: None');
    }
    if (options.data != null && options.data.toString().isNotEmpty) {
      buffer.writeln(
        'Data: ${_encoder.convert(options.data is FormData ? convertFormDataToObject(options.data) : options.data)}',
      );
    } else {
      buffer.writeln('Data: None');
    }

    if (options.extra.isNotEmpty) {
      buffer.writeln('Extra:');
      options.extra.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
    } else {
      buffer.writeln('Extra: None');
    }

    return buffer.toString();
  }

  void logRequest(RequestOptions requestOptions) {
    AppLogger.verbose(
      "API Request : \n${requestDetails(requestOptions)}",
      onlyValue: true,
    );
  }

  void logResponse(Response response) {
    AppLogger.verbose(
      "API Response from ${requestDetails(response.requestOptions)}"
      "Response :\n${_encoder.convert(response.data)}",
      onlyValue: true,
    );
  }

  void logError(DioException err) {
    AppLogger.error(
      "API Error from ${requestDetails(err.requestOptions)}"
      "Error :$err\nResponse: ${err.response?.data}",
    );
  }
}
