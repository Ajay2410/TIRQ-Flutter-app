import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

import '../../api_endpoints.dart';
import '../../services/language.service.dart';
import '../../core/models/service_pricing_model.dart';
import '../../resources/app_resources/app_resources.dart';
import '../../services/api.service.dart';
import '../../core/locator.dart';

class SetServicePricingViewModel extends BaseViewModel {
  final TextEditingController onlineInWarrantyController =
      TextEditingController();
  final TextEditingController onlineOutOfWarrantyController =
      TextEditingController();

  final TextEditingController offlineInWarrantyGeneralController =
      TextEditingController();
  final TextEditingController offlineInWarrantyFullServiceController =
      TextEditingController();
  final TextEditingController offlineOutOfWarrantyController =
      TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  List<Datum> _servicePricingData = [];

  String _onlineInWarrantyCurrency = 'USD';
  String _onlineOutOfWarrantyCurrency = 'USD';
  String _offlineInWarrantyGeneralCurrency = 'USD';
  String _offlineInWarrantyFullServiceCurrency = 'USD';
  String _offlineOutOfWarrantyCurrency = 'USD';

  final ApiService _apiService = locator<ApiService>();

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;

  List<Datum> get servicePricingData => _servicePricingData;

  String get onlineInWarrantyCurrency => _onlineInWarrantyCurrency;

  String get onlineOutOfWarrantyCurrency => _onlineOutOfWarrantyCurrency;

  String get offlineInWarrantyGeneralCurrency =>
      _offlineInWarrantyGeneralCurrency;

  String get offlineInWarrantyFullServiceCurrency =>
      _offlineInWarrantyFullServiceCurrency;

  String get offlineOutOfWarrantyCurrency => _offlineOutOfWarrantyCurrency;

  void init() {
    loadServicePricing();
  }

  @override
  void dispose() {
    onlineInWarrantyController.dispose();
    onlineOutOfWarrantyController.dispose();
    offlineInWarrantyGeneralController.dispose();
    offlineInWarrantyFullServiceController.dispose();
    offlineOutOfWarrantyController.dispose();
    super.dispose();
  }

  Future<void> loadServicePricing() async {
    _setLoading(true);

    try {
      final response = await _apiService.get(
        url: ApiEndpoints.getAllServicePricing,
        showToast: false,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData['data'] is List) {
          final dataList = responseData['data'] as List;
          _servicePricingData =
              dataList.map((item) => Datum.fromJson(item)).toList();
          _populateControllers();
        }
      } else {}
    } catch (e) {
    } finally {
      _setLoading(false);
    }
  }

  void _populateControllers() {
    for (final item in _servicePricingData) {
      if (item.supportMode == 'Online') {
        if (item.warrantyStatus == 'In warranty') {
          onlineInWarrantyController.text = item.cost?.toString() ?? '0';
          _onlineInWarrantyCurrency = item.currency ?? 'USD';
        } else if (item.warrantyStatus == 'Out of warranty') {
          onlineOutOfWarrantyController.text = item.cost?.toString() ?? '0';
          _onlineOutOfWarrantyCurrency = item.currency ?? 'USD';
        }
      } else if (item.supportMode == 'Offline') {
        if (item.warrantyStatus == 'In warranty' &&
            item.ticketType == 'General Check Up') {
          offlineInWarrantyGeneralController.text =
              item.cost?.toString() ?? '0';
          _offlineInWarrantyGeneralCurrency = item.currency ?? 'USD';
        } else if (item.warrantyStatus == 'In warranty' &&
            item.ticketType == 'Full Machine Service') {
          offlineInWarrantyFullServiceController.text =
              item.cost?.toString() ?? '0';
          _offlineInWarrantyFullServiceCurrency = item.currency ?? 'USD';
        } else if (item.warrantyStatus == 'Out of warranty' &&
            item.ticketType == 'Full Machine Service') {
          offlineOutOfWarrantyController.text = item.cost?.toString() ?? '0';
          _offlineOutOfWarrantyCurrency = item.currency ?? 'USD';
        }
      }
    }
    notifyListeners();
  }

  Future<void> saveServicePricing(BuildContext context) async {
    if (!validatePricing()) {
      return;
    }

    _setSaving(true);
    _setError(null);

    try {
      final requestBody = {
        "supportPricing": [
          {
            "supportMode": "Online",
            "warrantyStatus": "In warranty",
            "ticketType": "General Check Up",
            "cost": int.tryParse(onlineInWarrantyController.text) ?? 0,
            "currency": _onlineInWarrantyCurrency,
          },
          {
            "supportMode": "Online",
            "warrantyStatus": "Out of warranty",
            "ticketType": "General Check Up",
            "cost": int.tryParse(onlineOutOfWarrantyController.text) ?? 0,
            "currency": _onlineOutOfWarrantyCurrency,
          },
          {
            "supportMode": "Offline",
            "warrantyStatus": "In warranty",
            "ticketType": "General Check Up",
            "cost": int.tryParse(offlineInWarrantyGeneralController.text) ?? 0,
            "currency": _offlineInWarrantyGeneralCurrency,
          },
          {
            "supportMode": "Offline",
            "warrantyStatus": "In warranty",
            "ticketType": "Full Machine Service",
            "cost":
                int.tryParse(offlineInWarrantyFullServiceController.text) ?? 0,
            "currency": _offlineInWarrantyFullServiceCurrency,
          },
          {
            "supportMode": "Offline",
            "warrantyStatus": "Out of warranty",
            "ticketType": "Full Machine Service",
            "cost": int.tryParse(offlineOutOfWarrantyController.text) ?? 0,
            "currency": _offlineOutOfWarrantyCurrency,
          },
        ],
      };

      final response = await _apiService.post(
        url: ApiEndpoints.createServicePricing,
        data: requestBody,
        showToast: true,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        String successMessage = LanguageService.get('service_pricing_saved');
        if (responseData is Map<String, dynamic> &&
            responseData['message'] != null) {
          successMessage = responseData['message'].toString();
        }

        Fluttertoast.showToast(msg: successMessage);
        navigateBack(context);
      }
    } catch (e) {
      _setError('${LanguageService.get('error_saving_pricing')}: $e');
    } finally {
      _setSaving(false);
    }
  }

  bool validatePricing() {
    final onlineInWarranty = int.tryParse(onlineInWarrantyController.text);
    final onlineOutOfWarranty = int.tryParse(
      onlineOutOfWarrantyController.text,
    );
    final offlineInWarrantyGeneral = int.tryParse(
      offlineInWarrantyGeneralController.text,
    );
    final offlineInWarrantyFullService = int.tryParse(
      offlineInWarrantyFullServiceController.text,
    );
    final offlineOutOfWarranty = int.tryParse(
      offlineOutOfWarrantyController.text,
    );

    if (onlineInWarranty == null ||
        onlineOutOfWarranty == null ||
        offlineInWarrantyGeneral == null ||
        offlineInWarrantyFullService == null ||
        offlineOutOfWarranty == null) {
      Fluttertoast.showToast(
        msg: LanguageService.get('valid_numbers_required'),
        backgroundColor: AppColors.redBack,
      );
      return false;
    }

    if (onlineInWarranty < 0 ||
        onlineOutOfWarranty < 0 ||
        offlineInWarrantyGeneral < 0 ||
        offlineInWarrantyFullService < 0 ||
        offlineOutOfWarranty < 0) {
      Fluttertoast.showToast(msg: LanguageService.get('pricing_negative'));
      return false;
    }

    return true;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSaving(bool saving) {
    _isSaving = saving;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  void updateCurrency(String currency, String fieldType) {
    switch (fieldType) {
      case 'onlineInWarranty':
        _onlineInWarrantyCurrency = currency;
        break;
      case 'onlineOutOfWarranty':
        _onlineOutOfWarrantyCurrency = currency;
        break;
      case 'offlineInWarrantyGeneral':
        _offlineInWarrantyGeneralCurrency = currency;
        break;
      case 'offlineInWarrantyFullService':
        _offlineInWarrantyFullServiceCurrency = currency;
        break;
      case 'offlineOutOfWarranty':
        _offlineOutOfWarrantyCurrency = currency;
        break;
    }
    notifyListeners();
  }
}
