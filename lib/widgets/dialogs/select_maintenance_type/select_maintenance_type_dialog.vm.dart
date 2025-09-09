import 'package:stacked/stacked.dart';

class SelectMaintenanceTypeDialogViewModel extends BaseViewModel {
  String? _selectedType;
  bool _isGeneralCheckUpDisabled = false;

  String? get selectedType => _selectedType;
  bool get isGeneralCheckUpDisabled => _isGeneralCheckUpDisabled;

  void init({bool isGeneralCheckUpDisabled = false}) {
    _isGeneralCheckUpDisabled = isGeneralCheckUpDisabled;

    // If General Check Up is disabled, automatically select Full Machine Service
    if (isGeneralCheckUpDisabled) {
      _selectedType = 'Full Machine Service';
    }

    notifyListeners();
  }

  void selectType(String type) {
    _selectedType = type;
    notifyListeners();
  }
}
