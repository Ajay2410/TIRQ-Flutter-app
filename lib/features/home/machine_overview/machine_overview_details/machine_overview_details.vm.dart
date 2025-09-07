import 'package:stacked/stacked.dart';
import 'package:manager/api_endpoints.dart';
import 'package:manager/core/models/machine_overview_details_model.dart';
import 'package:manager/services/api.service.dart';
import 'package:manager/core/locator.dart';

class MachineOverviewDetailsViewModel extends BaseViewModel {
  final _apiService = locator<ApiService>();

  MachineOverviewDetailsModel? _machineDetails;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String? _machineId;
  bool _hasChanges = false;

  MachineOverviewDetailsModel? get machineDetails => _machineDetails;

  bool get isLoading => _isLoading;

  @override
  bool get hasError => _hasError;

  String get errorMessage => _errorMessage;
  bool get hasChanges => _hasChanges;

  void init(String machineId) {
    _machineId = machineId;
    _loadMachineDetails();
  }

  Future<void> _loadMachineDetails() async {
    if (_machineId == null) return;

    _setLoading(true);
    _hasError = false;
    _errorMessage = '';

    try {
      final response = await _apiService.get(
        url: '${ApiEndpoints.getMachineById}/$_machineId',
      );

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

  bool get hasProcessingDimensions =>
      _machineDetails?.processingDimensions != null;

  ProcessingDimensions? get processingDimensions =>
      _machineDetails?.processingDimensions;

  void markAsChanged() {
    _hasChanges = true;
    notifyListeners();
  }
}
