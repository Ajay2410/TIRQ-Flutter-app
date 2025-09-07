import 'package:stacked/stacked.dart';
import 'package:manager/core/models/customer.dart';
import 'package:manager/services/customer.service.dart';
import 'package:manager/core/locator.dart';

class CustomerDetailsViewModel extends BaseViewModel {
  final CustomerService _customerService = locator<CustomerService>();

  Customer? _customer;
  String? _customerId;
  String _errorMessage = '';
  bool _hasChanges = false;

  Customer? get customer => _customer;

  String get errorMessage => _errorMessage;

  bool get hasChanges => _hasChanges;

  void init(String customerId) {
    _customerId = customerId;
    _loadCustomerDetails();
  }

  Future<void> _loadCustomerDetails() async {
    if (_customerId == null) return;

    setBusy(true);
    _errorMessage = '';

    try {
      final result = await _customerService.getCustomerById(_customerId!);

      result.fold(
        (failure) {
          _errorMessage = failure.message;
          setError(true);
        },
        (customer) {
          _customer = customer;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      setError(true);
    } finally {
      setBusy(false);
    }
  }

  Future<void> refreshCustomerDetails() async {
    await _loadCustomerDetails();
  }

  void markAsChanged() {
    _hasChanges = true;
    notifyListeners();
  }
}
