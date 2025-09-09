import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/services/api.service.dart';
import 'package:manager/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class SupplierMachineDetailsViewModel extends BaseViewModel {
  final _apiService = locator<ApiService>();

  String? _machineId;
  String? _organizationId;

  void init(String machineId, String organizationId) {
    _machineId = machineId;
    _organizationId = organizationId;
  }

  /// Create a ticket with the provided details - Direct API call
  Future<void> createTicket({
    String? problem,
    String? errorCode,
    String? additionalNotes,
    List<File>? attachments,
    String? maintenanceType,
    bool isFromSiteVisit = false,
  }) async {
    if (_machineId == null) {
      AppLogger.error('Machine ID is null');
      Fluttertoast.showToast(msg: 'Machine ID not found', backgroundColor: Colors.red);
      return;
    }

    if (_organizationId == null) {
      AppLogger.error('Organization ID is null');
      Fluttertoast.showToast(msg: 'Organization ID not found', backgroundColor: Colors.red);
      return;
    }

    if (isFromSiteVisit) {
      // For site visit, only send ticketType, machineId, and organisationId
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('ticketType', maintenanceType!),
        MapEntry('machineId', _machineId!),
        MapEntry('organisationId', _organizationId!),
      ]);

      final response = await _apiService.post(url: ApiEndpoints.createTicket, data: formData);

      if (response.statusCode == 201 && response.data['ticket'] != null) {
        AppLogger.info('Site visit ticket created successfully: ${response.data['ticket']['_id']}');
        Fluttertoast.showToast(msg: response.data["message"] ?? 'Site visit ticket created successfully!', backgroundColor: Colors.green);
      } else {
        AppLogger.error('Failed to create site visit ticket');
      }
    } else {
      // For regular ticket creation with all fields
      final formData = FormData();

      // Add text fields
      formData.fields.addAll([
        MapEntry('problem', problem!),
        MapEntry('errorCode', errorCode!),
        MapEntry('notes', additionalNotes!),
        MapEntry('machineId', _machineId!),
        MapEntry('organisationId', _organizationId!),
      ]);

      // Add image files
      for (var i = 0; i < attachments!.length; i++) {
        final file = attachments[i];
        final extension = file.path.split('.').last.toLowerCase();
        final contentType = extension == 'png' ? DioMediaType('image', 'png') : DioMediaType('image', 'jpeg');

        formData.files.add(
          MapEntry('ticketImages', await MultipartFile.fromFile(file.path, filename: 'ticket_image_$i.$extension', contentType: contentType)),
        );
      }

      final response = await _apiService.post(url: ApiEndpoints.createTicket, data: formData);

      if (response.statusCode == 201 && response.data['ticket'] != null) {
        AppLogger.info('Ticket created successfully: ${response.data['ticket']['_id']}');
        Fluttertoast.showToast(msg: response.data["message"] ?? 'Ticket created successfully!', backgroundColor: Colors.green);
      } else {
        AppLogger.error('Failed to create ticket');
      }
    }
  }
}
