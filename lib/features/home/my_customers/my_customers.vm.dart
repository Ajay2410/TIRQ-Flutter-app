import 'package:manager/core/models/customer.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import '../../../core/locator.dart';
import '../../../routes/routes.dart';
import '../../../services/api.service.dart';
import '../../../api_endpoints.dart';
import '../../../services/language.service.dart';
import 'search_organization/search_organization.view.dart';
import 'create_customer/create_new_customer.view.dart';

class MyCustomersViewModel extends BaseViewModel {
  final _apiService = locator<ApiService>();

  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  String _searchQuery = '';
  String _statusFilter = 'all';
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  List<Customer> get customers => _customers;
  List<Customer> get filteredCustomers => _filteredCustomers;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  bool get isLoading => _isLoading;
  @override
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  void init() {
    _searchQuery = '';
    _statusFilter = 'all';
    _loadCustomers();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
  }

  Future<void> _loadCustomers() async {
    _setLoading(true);
    _hasError = false;
    _errorMessage = '';

    try {
      final response = await _apiService.get(url: ApiEndpoints.getCustomers);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['data'] != null) {
          final List<dynamic> customersData = data['data'];
          _customers =
              customersData.map((json) => Customer.fromJson(json)).toList();
          _filteredCustomers = _customers;
        } else {
          _customers = [];
          _filteredCustomers = [];
        }
      } else {
        _hasError = true;
        _errorMessage = LanguageService.get('failed_to_load_customers');
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

  Future<void> refreshCustomers() async {
    await _loadCustomers();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void onStatusFilterChanged(String status) {
    if (_statusFilter == status) {
      _statusFilter = 'all';
    } else {
      _statusFilter = status;
    }
    _applyFilters();
  }

  void _applyFilters() {
    _filteredCustomers =
        _customers.where((customer) {
          bool matchesSearch =
              _searchQuery.isEmpty ||
              customer.customerName?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ==
                  true;

          bool matchesStatus =
              _statusFilter == 'all' ||
              (customer.isActive == true ? 'active' : 'inactive') ==
                  _statusFilter.toLowerCase();

          return matchesSearch && matchesStatus;
        }).toList();

    notifyListeners();
  }

  void onAddNewCustomer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => CreateNewCustomerView(
              onCustomerCreated: () {
                _loadCustomers();
              },
            ),
      ),
    );
  }

  void onScanFromCamera() {
    // TODO: Implement QR scan functionality
  }

  void onSearchByPhone(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SearchOrganizationView()),
    );
  }

  void onCustomerTap(BuildContext context, Customer customer) {
    Navigator.of(
      context,
    ).pushNamed(Routes.customerDetails, arguments: customer);
  }
}
