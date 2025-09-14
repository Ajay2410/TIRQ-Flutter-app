import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/employee.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/type_def.dart';
import 'package:manager/services/api.service.dart';

import '../core/models/hive/user/user.dart';
import '../core/utils/failures.dart';

class EmployeeService {
  final apiService = locator<ApiService>();

  ResultFuture<List<Employee>> getEmployees({
    required String? role,
    required String? employeeType,
  }) async {
    try {
      final response = await apiService.get(
        url: ApiEndpoints.getEmployees,
        queryParameters: {'role': role, 'type': employeeType},
      );

      if (response.data['success'] == true) {
        return Right(
          (response.data['data'] as List)
              .map((e) => Employee.fromJson(e))
              .toList(),
        );
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
    return Left(Failure('Failed to get employees'));
  }

  ResultFuture<List<Employee>> getAllEmployees() async {
    // try {
    //   final response = await apiService.get(
    //     url: ApiEndpoints.allEmployee,
    //   );

    // if (response.data['success'] == true) {
    //   return Right(
    //     (response.data['data'] as List)
    //         .map((e) => Employee.fromJson(e))
    //         .toList(),
    //   );
    // } else {
    //   return Left(Failure(response.data['message']));
    // }
    // } catch (e) {
    //   if (e is DioException) {
    //     AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
    //     return Left(
    //       Failure(e.response?.data?['message'] ?? 'Something went wrong'),
    //     );
    //   }
    // }
    return Left(Failure('Failed to get all employees'));
  }

  ResultFuture<Employee> getPendingEmployeeById(String id) async {
    try {
      final response = await apiService.get(
        url: '${ApiEndpoints.employee}/$id',
      );

      if (response.data['success'] == true) {
        return Right(Employee.fromJson(response.data['data']));
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
    return Left(Failure('Failed to get employees'));
  }

  ResultFuture<bool> createEmployee({
    required String id,
    required String relationshipType,
    required String team,
    required DateTime startDateTime,
    required String country,
    required bool canViewCalendar,
    required bool canAssignTasks,
    required bool canViewPerformance,
    required bool canApproveExpenses,
    required bool canApproveTimeOff,
    required String role,
    String? reportingTo,
    String? assignMachine,
    String? factoryUnitId,
    String? employeeId,
    String? countryCode,
    String? emergencyContact,
    String? employmentType,
    String? shiftTiming,
    DateTime? endDateTime,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.employee,
        data: {
          "employeeId": id,
          "relationshipType": relationshipType,
          "teamContext": team,
          "startDate": startDateTime.toIso8601String(),
          "endDate": endDateTime?.toIso8601String(),
          "role": role,
          "country": country,
          "permissions": {
            "canViewCalendar": canViewCalendar,
            "canAssignTasks": canAssignTasks,
            "canViewPerformance": canViewPerformance,
            "canApproveTimeOff": canApproveTimeOff,
            "canApproveExpenses": canApproveExpenses,
          },
          "factoryUnitId": factoryUnitId,
          "employee_Id": employeeId,
          "reportingTo": reportingTo,
          "assignMachine": assignMachine,
          "countryCode": countryCode,
          "emergencyContact": emergencyContact,
          "employmentStatus": employmentType,
          "shift": shiftTiming,
        },
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
    return Left(Failure('Failed to create employee'));
  }

  ResultFuture<bool> addNewEmployee({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String countryCode,
    required String relationshipType,
    required String team,
    required String country,
    required DateTime startDateTime,

    required bool canViewCalendar,
    required bool canAssignTasks,
    required bool canViewPerformance,
    required bool canApproveExpenses,
    required bool canApproveTimeOff,
    required String role,
    String? reportingTo,
    String? assignMachine,
    String? factoryUnitId,
    String? employeeId,
    String? countryName,
    String? emergencyContact,
    String? employmentType,
    String? shiftTiming,
    DateTime? endDateTime,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.addNewEmployee,
        data: {
          "fullName": fullName,
          "email": email,
          'phone': phone,
          "password": password,
          "countryCode": countryCode,
          "relationshipType": relationshipType,
          "teamContext": team,
          "country": country,
          "startDate": startDateTime.toIso8601String(),
          "endDate": endDateTime?.toIso8601String(),
          "role": role,
          "permissions": {
            "canViewCalendar": canViewCalendar,
            "canAssignTasks": canAssignTasks,
            "canViewPerformance": canViewPerformance,
            "canApproveTimeOff": canApproveTimeOff,
            "canApproveExpenses": canApproveExpenses,
          },
          "factoryUnitId": factoryUnitId,
          "employee_Id": employeeId,
          "reportingTo": reportingTo,
          "assignMachine": assignMachine,
          "countryName": countryName,
          "emergencyContact": emergencyContact,
          "employmentStatus": employmentType,
          "shift": shiftTiming,
        },
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
    return Left(Failure('Failed to create employee'));
  }

  ResultFuture<bool> updateEmployee(
    String employeeId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await apiService.put(
        url: '${ApiEndpoints.employee}/$employeeId',
        data: updateData,
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
    return Left(Failure('Failed to update employee'));
  }

  ResultFuture<bool> deleteEmployee(String employeeId) async {
    try {
      final response = await apiService.delete(
        url: '${ApiEndpoints.employee}/$employeeId',
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
    return Left(Failure('Failed to delete employee'));
  }

  ResultFuture<bool> updateEmployeePermissions(
    String employeeId,
    Map<String, dynamic> permissions,
  ) async {
    try {
      final response = await apiService.put(
        url: '${ApiEndpoints.employee}/$employeeId/permissions',
        data: {'permissions': permissions},
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
    return Left(Failure('Failed to update employee permissions'));
  }

  ResultFuture<bool> toggleEmployeeStatus(
    String employeeId,
    String status,
  ) async {
    try {
      final response = await apiService.put(
        url: '${ApiEndpoints.employee}/$employeeId/status',
        data: {'accountStatus': status},
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
    return Left(Failure('Failed to update employee status'));
  }
}
