import 'package:flutter/material.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/services/api.service.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/models/customer.dart';
import 'package:manager/widgets/dialogs/loader/loader_dialog.view.dart';
import 'package:manager/services/dialogs.service.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/features/home/my_customers/machine_details/customer_details/customer_edit_details.view.dart';

class ScanCodeViewModel extends BaseViewModel {
  final _apiService = locator<ApiService>();
  final _dialogService = locator<DialogService>();

  bool _isScanning = true;
  bool _isProcessing = false;
  DateTime? _lastScanTime;

  bool get isScanning => _isScanning;

  bool get isProcessing => _isProcessing;

  void setScanning(bool value) {
    _isScanning = value;
    notifyListeners();
  }

  Future<void> handleScannedCode(String code, BuildContext context) async {
    if (!_isScanning || _isProcessing) return;

    final now = DateTime.now();
    if (_lastScanTime != null && now.difference(_lastScanTime!).inSeconds < 4) {
      AppLogger.info('Scan ignored - too soon after last scan');
      return;
    }

    _lastScanTime = now;
    _isProcessing = true;
    setScanning(false);

    try {
      AppLogger.info('Scanned code: $code');
      await Future.delayed(Duration(milliseconds: 500));

      final response = await _dialogService.showCustomDialog(
        variant: DialogType.loader,
        data: LoaderDialogAttributes(
          task: () async {
            try {
              final apiResponse = await _apiService.get(
                url: '${ApiEndpoints.getCustomerById}/$code',
              );

              AppLogger.info("API Response: ${apiResponse.data}");

              if (apiResponse.statusCode == 200) {
                final customer = Customer.fromJson(apiResponse.data);
                return customer;
              } else {
                throw Exception(
                  apiResponse.data?['message'] ?? 'Failed to fetch customer',
                );
              }
            } catch (e) {
              AppLogger.error("Error fetching customer: $e");
              throw e;
            }
          },
          message: 'Fetching customer data...',
        ),
      );

      if (response?.confirmed == true && response?.data is Customer) {
        final customer = response!.data as Customer;
        _navigateToCustomerEditDetails(context, customer);
      } else {
        _handleError(response?.data ?? "Unknown error");
      }
    } catch (e) {
      _handleError(e.toString());
    } finally {
      _isProcessing = false;
    }
  }

  void _navigateToCustomerEditDetails(
    BuildContext context,
    Customer customer,
  ) async {
    final editResult = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => CustomerEditDetailsView(
              customer: customer,
              isFromSearchOrganization: false,
            ),
      ),
    );

    if (editResult != null && editResult is Customer) {
      // Navigate back to my_customers and refresh
      Navigator.of(context).pop(true);
    }
  }

  void _handleError(String errorMessage) {
    _isProcessing = false;
    setScanning(true);
  }

  void resetScanning() {
    setScanning(true);
  }
}
