import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
            'language' : locator<UserService>().selectedLanguage,
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
              gravity: ToastGravity.TOP,
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

  Future<Response> get({
    required String url,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    String? baseUrl,
    Options? options,
  }) async {
    try {
      var response = await _dio.get(
        "${baseUrl ?? _config.baseUrl}$url",
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
      return response;
    } on DioException {
      rethrow;
    } on Exception {
      rethrow;
    }
  }

  Future<Response> post({
    required String url,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    CancelToken? cancelToken,
    Options? options,
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
    } on DioException {
      rethrow;
    } on Exception {
      rethrow;
    }
  }

  Future<Response> put({
    required String url,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    CancelToken? cancelToken,
    Options? options,
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
    } on DioException {
      rethrow;
    } on Exception {
      rethrow;
    }
  }

  Future<Response> delete({
    required String url,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    CancelToken? cancelToken,
    Options? options,
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
    } on DioException {
      rethrow;
    } on Exception {
      rethrow;
    }
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
