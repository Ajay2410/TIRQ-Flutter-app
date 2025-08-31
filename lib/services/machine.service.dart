import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/machine.dart';
import 'package:manager/core/models/machine_model.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/core/utils/type_def.dart';
import 'package:manager/features/machines/machines_list/machines_list.vm.dart';
import 'package:manager/services/api.service.dart';

import '../core/utils/failures.dart';

class MachineService {
  final apiService = locator<ApiService>();

  ResultFuture<MachinesListInfo> getMachines({
    required String? status,
    required String? department,
    required String manufacturerId,
    required String? processorId,
  }) async {
    try {
      final response = await apiService.get(
        url: ApiEndpoints.machine,
        queryParameters: {
          'status': status,
          'department': department,
          'manufacturerId': manufacturerId,
          'processorId': processorId,
        },
      );

      if (response.data['success'] == true) {
        return Right(MachinesListInfo.fromJson(response.data['data']));
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
    return Left(Failure('Failed to get machines'));
  }

  ResultFuture<List<Machine>> getMyMachines({String? status}) async {
    try {
      final response = await apiService.get(
        url: ApiEndpoints.getMyMachines,
        queryParameters: {'status': status ?? 'All'},
      );

      if (response.data['success'] == true) {
        return Right(
          (response.data['data'] as List)
              .map((e) => Machine.fromJson(e))
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
    return Left(Failure('Failed to get machines'));
  }

  ResultFuture<Machine> getMachineById({
    required String machineId,
    String? processorId,
  }) async {
    try {
      final response = await apiService.get(
        url: ApiEndpoints.machine,
        queryParameters: {
          'machineId': machineId,
          'processorId': processorId ?? '',
        },
      );

      if (response.data['success'] == true) {
        return Right(Machine.fromJson(response.data['data']['machines'][0]));
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
    return Left(Failure('Failed to get machine details'));
  }

  ResultFuture<bool> createMachine({
    required String machineName,
    required String modelNumber,
    required int operatingHours,
    required Map<String, dynamic> technicalSpecifications,
    List<String>? assignedTechnicians,
    required Map<String, dynamic> warranty,
    required String purchaseDate,
  }) async {
    try {
      final response = await apiService.post(
        url: ApiEndpoints.machine,
        data: {
          "machineName": machineName,
          "modelNumber": modelNumber,
          'serialNumber': modelNumber,
          "operatingHours": operatingHours,
          "technicalSpecifications": technicalSpecifications,
          if (assignedTechnicians != null && assignedTechnicians.isNotEmpty)
            "assignedTechnicians": assignedTechnicians,
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
    return Left(Failure('Failed to create machine'));
  }

  /// Create a new machine with the new API structure
  ResultFuture<Datum> createMachineNew({
    required String machineName,
    required String modelNumber,
    required String serialNumber,
    required String machineType,
    required Map<String, dynamic> processingDimensions,
    required int totalPower,
    required String manualsLink,
    required String notes,
    required String status,
    required String remarks,
  }) async {
    try {
      AppLogger.info("Creating new machine: $machineName");

      final Map<String, dynamic> requestData = {
        'machineName': machineName,
        'modelNumber': modelNumber,
        'serialNumber': serialNumber,
        'machine_type': machineType,
        'processingDimensions': processingDimensions,
        'totalPower': totalPower,
        'manualsLink': manualsLink,
        'notes': notes,
        'status': status,
        'remarks': remarks,
      };

      AppLogger.info("Request data: $requestData");

      final response = await apiService.post(
        url: ApiEndpoints.createMachine,
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        if (data != null && data['data'] != null) {
          final machine = Datum.fromJson(data['data']);
          AppLogger.info("Machine created successfully: ${machine.id}");
          return Right(machine);
        } else {
          AppLogger.error("Invalid response format: $data");
          return Left(Failure('Invalid response format'));
        }
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Failed to create machine';
        AppLogger.error(
          "API error: $errorMessage (Status: ${response.statusCode})",
        );
        return Left(Failure(errorMessage));
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? 'Network error occurred';
      AppLogger.error("DioException while creating machine: $errorMessage");
      return Left(Failure(errorMessage));
    } catch (e) {
      AppLogger.error("Exception while creating machine: $e");
      return Left(Failure('Unexpected error occurred: $e'));
    }
  }

  ResultFuture<bool> updateMachine({
    required String machineId,
    required String processorId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      // If assignedTechnicians is passed, ensure it's handled correctly
      final response = await apiService.put(
        url: '${ApiEndpoints.machine}/update',
        data: updateData,
        queryParameters: {'machineId': machineId, 'processorId': processorId},
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
    return Left(Failure('Failed to update machine'));
  }

  ResultFuture<bool> deleteMachine(String machineId) async {
    try {
      final response = await apiService.delete(
        url: '${ApiEndpoints.deleteMachine}/$machineId',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.data is Map<String, dynamic>) {
          final body = response.data as Map<String, dynamic>;
          if (body['success'] == true) {
            return Right(true);
          } else {
            final msg = body['message'] ?? 'Delete failed';
            return Left(Failure(msg));
          }
        }
        return Right(true);
      }
      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        final msg = body['message'] ?? 'Failed to delete machine';
        return Left(Failure(msg));
      }

      return Left(Failure('Server returned ${response.statusCode}'));
    } catch (e) {
      if (e is DioException) {
        final errData = e.response?.data;
        if (errData is Map<String, dynamic> && errData['message'] != null) {
          return Left(Failure(errData['message']));
        }
        final code = e.response?.statusCode;
        return Left(Failure('DELETE failed with status $code: ${e.message}'));
      }
      return Left(Failure('Unexpected error: ${e.toString()}'));
    }
  }

  ResultFuture<MachineModel> getAllMachines() async {
    try {
      final response = await apiService.get(url: ApiEndpoints.getAllMachines);

      if (response.data['success'] == true || response.statusCode == 200) {
        return Right(MachineModel.fromJson(response.data));
      } else {
        return Left(
          Failure(response.data['message'] ?? 'Failed to get machines'),
        );
      }
    } catch (e) {
      if (e is DioException) {
        AppLogger.error(e.response?.data?['message'] ?? 'Something went wrong');
        return Left(
          Failure(e.response?.data?['message'] ?? 'Something went wrong'),
        );
      }
      return Left(Failure('Failed to get machines: ${e.toString()}'));
    }
  }
}
