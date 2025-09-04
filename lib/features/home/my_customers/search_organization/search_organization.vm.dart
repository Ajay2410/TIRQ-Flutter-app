import 'package:stacked/stacked.dart';
import 'package:manager/core/models/customer.dart';
import 'package:manager/services/customer.service.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/utils/helpers/debounce.dart';
import 'package:manager/core/utils/failures.dart';

class SearchOrganizationViewModel extends BaseViewModel {
  final CustomerService _customerService = locator<CustomerService>();
  final Debouncer _debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  List<Customer> _searchResults = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<Customer> get searchResults => _searchResults;

  String get searchQuery => _searchQuery;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void performSearch(String query) {
    if (query.isEmpty || query.trim().isEmpty) {
      _clearSearch();
      return;
    }

    if (query.trim().length < 2) {
      return;
    }

    _debouncer.call(() async {
      await _searchCustomers(query.trim());
    });
  }

  Future<void> _searchCustomers(String query) async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      final result = await _customerService.searchCustomers(query);

      result.fold(
        (failure) {
          _setError(_getErrorMessage(failure));
          _searchResults = [];
        },
        (customers) {
          _searchResults = customers;
        },
      );
    } catch (e) {
      _setError('An unexpected error occurred');
      _searchResults = [];
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _clearSearch() {
    _searchResults.clear();
    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(Failure failure) {
    return failure.message;
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults.clear();
    _errorMessage = null;
    _debouncer.dispose();
    notifyListeners();
  }

  void cancelSearch() {
    _debouncer.dispose();
    _setLoading(false);
    _clearError();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }
}
