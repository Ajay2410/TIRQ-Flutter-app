import 'package:manager/core/models/customer.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../core/locator.dart';
import '../../../routes/routes.dart';
import 'search_organization/search_organization.view.dart';
import 'create_customer/create_new_customer.view.dart';

class MyCustomersViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  String _searchQuery = '';
  String _statusFilter = 'all';

  List<Customer> get customers => _customers;
  List<Customer> get filteredCustomers => _filteredCustomers;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  void init() {
    _loadCustomers();
  }

  void _loadCustomers() {
    // Mock data - replace with actual API call
    _customers = [
      Customer(
        id: '1',
        name: 'Leslie Alexander',
        companyIcon: 'C&R',
        flag: AppImages.egyptFlag,
        description: 'Model No 1, Model No 2, Model No 3',
        status: 'Active',
        avatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      ),
      Customer(
        id: '2',
        name: 'Courtney Henry',
        companyIcon: 'SPPPIC',
        flag: AppImages.egyptFlag,
        description: 'Model No 1, Model No 2, Model No 3',
        status: 'Active',
        avatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      ),
      Customer(
        id: '3',
        name: 'Leslie Alexander',
        companyIcon: 'C&R',
        flag: AppImages.egyptFlag,
        description: 'Model No 1, Model No 2, Model No 3',
        status: 'Active',
        avatar:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
      ),
      Customer(
        id: '4',
        name: 'Courtney Henry',
        companyIcon: 'SPPPIC',
        flag: AppImages.egyptFlag,
        description: 'Depart Name/ Tag line',
        status: 'Active',
        avatar:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face',
      ),
      Customer(
        id: '5',
        name: 'Leslie Alexander',
        companyIcon: 'C&R',
        flag: AppImages.egyptFlag,
        description: 'Depart Name/ Tag line',
        status: 'Active',
        avatar:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop&crop=face',
      ),
      Customer(
        id: '6',
        name: 'Courtney Henry',
        companyIcon: 'SPPPIC',
        flag: AppImages.egyptFlag,
        description: 'Depart Name/ Tag line',
        status: 'Inactive',
        avatar:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop&crop=face',
      ),
      Customer(
        id: '7',
        name: 'Leslie Alexander',
        companyIcon: 'C&R',
        flag: AppImages.egyptFlag,
        description: 'Model No 1, Model No 2, Model No 3',
        status: 'Inactive',
        avatar:
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop&crop=face',
      ),
      Customer(
        id: '8',
        name: 'Courtney Henry',
        companyIcon: 'SPPPIC',
        flag: AppImages.egyptFlag,
        description: 'Depart Name/ Tag line',
        status: 'Inactive',
        avatar:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop&crop=face',
      ),
      Customer(
        id: '9',
        name: 'Leslie Alexander',
        companyIcon: 'C&R',
        flag: AppImages.egyptFlag,
        description: 'Depart Name/ Tag line',
        status: 'Active',
        avatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      ),
    ];
    _filteredCustomers = _customers;
    notifyListeners();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void onStatusFilterChanged(String status) {
    // If the same filter is pressed again, set it to 'all' (toggle behavior)
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
              customer.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              customer.description.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );

          bool matchesStatus =
              _statusFilter == 'all' ||
              customer.status.toLowerCase() == _statusFilter.toLowerCase();

          return matchesSearch && matchesStatus;
        }).toList();

    notifyListeners();
  }

  void onAddNewCustomer() {
    // Navigate to add customer screen
    _navigationService.navigateToView(const CreateNewCustomerView());
  }

  void onScanFromCamera() {
    // Navigate to camera/gallery scanner
    // _navigationService.navigateTo(Routes.scanQr);
  }

  void onSearchByPhone() {
    // Navigate to search by phone/email screen
    _navigationService.navigateToView(const SearchOrganizationView());
  }

  void onCustomerTap(Customer customer) {
    // Navigate to customer details screen
    _navigationService.navigateTo(Routes.customerDetails, arguments: customer);
  }
}
