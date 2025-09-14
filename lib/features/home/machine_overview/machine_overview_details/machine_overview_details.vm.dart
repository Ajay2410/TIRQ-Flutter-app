import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/models/machine_overview_details_model.dart';
import 'package:manager/services/api.service.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:manager/routes/routes.dart';
import 'dart:io';

class MachineOverviewDetailsViewModel extends BaseViewModel {
  final _apiService = locator<ApiService>();
  final _navigationService = locator<NavigationService>();

  MachineOverviewDetailsModel? _machineDetails;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String? _machineId;
  String? _organizationId;
  bool _hasChanges = false;

  MachineOverviewDetailsModel? get machineDetails => _machineDetails;

  bool get isLoading => _isLoading;

  @override
  bool get hasError => _hasError;

  String get errorMessage => _errorMessage;

  bool get hasChanges => _hasChanges;

  void init(String machineId, String organizationId) {
    _machineId = machineId;
    _organizationId = organizationId;
    _loadMachineDetails();
  }

  Future<void> _loadMachineDetails() async {
    if (_machineId == null) return;

    _setLoading(true);
    _hasError = false;
    _errorMessage = '';

    try {
      final response = await _apiService.get(url: '${ApiEndpoints.getMachineById}/$_machineId');

      if (response.statusCode == 200) {
        _machineDetails = MachineOverviewDetailsModel.fromJson(response.data);
      } else {
        _hasError = true;
        _errorMessage = 'Failed to load machine details. Please try again.';
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> refreshMachineDetails() async {
    await _loadMachineDetails();
  }

  bool get hasProcessingDimensions => _machineDetails?.processingDimensions != null;

  ProcessingDimensions? get processingDimensions => _machineDetails?.processingDimensions;

  void markAsChanged() {
    _hasChanges = true;
    notifyListeners();
  }

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

    if (_organizationId == null || _organizationId!.isEmpty) {
      AppLogger.error('Organization ID is null or empty');
      Fluttertoast.showToast(msg: 'Organization ID not found', backgroundColor: Colors.red);
      return;
    }

    if (isFromSiteVisit) {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('ticketType', maintenanceType!),
        MapEntry('machineId', _machineId!),
        MapEntry('organisationId', _organizationId!),
        MapEntry('problem', ""),
        MapEntry('errorCode', ""),
        MapEntry('notes', ""),
        MapEntry('paymentStatus', "unpaid"),
        MapEntry('type', "Offline"),
      ]);

      final response = await _apiService.post(url: ApiEndpoints.createTicket, data: formData);

      if (response.statusCode == 201 && response.data['ticket'] != null) {
        final ticketId = response.data['ticket']['_id'];
        AppLogger.info('Site visit ticket created successfully: $ticketId');
        Fluttertoast.showToast(msg: response.data["message"] ?? 'Site visit ticket created successfully!', backgroundColor: Colors.green);
        await _navigationService.navigateTo(Routes.reviewTicket, arguments: ticketId);
      } else {
        AppLogger.error('Failed to create site visit ticket');
      }
    } else {
      final formData = FormData();

      formData.fields.addAll([
        MapEntry('problem', problem!),
        MapEntry('errorCode', errorCode!),
        MapEntry('notes', additionalNotes!),
        MapEntry('machineId', _machineId!),
        MapEntry('organisationId', _organizationId!),
        MapEntry('ticketType', "Full Machine Service"),
        MapEntry('paymentStatus', "unpaid"),
        MapEntry('type', "Online"),
      ]);

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
        final ticketId = response.data['ticket']['_id'];
        AppLogger.info('Ticket created successfully: $ticketId');
        Fluttertoast.showToast(msg: response.data["message"] ?? 'Ticket created successfully!', backgroundColor: Colors.green);
        await _navigationService.navigateTo(Routes.reviewTicket, arguments: ticketId);
      } else {
        AppLogger.error('Failed to create ticket');
      }
    }
  }
}
