import 'package:manager/core/models/employee.dart';
import 'package:manager/core/models/organization.dart';
import 'package:manager/core/models/customer.dart';
import 'package:manager/features/profile/create_or_edit_org/create_or_edit_org.view.dart';
import 'package:manager/routes/routes.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/models/hive/user/user.dart';
import '../../../core/storage/storage.dart';
import '../../../services/account.service.dart';
import '../../../services/auth.service.dart';
import '../../../services/employee_profile.service.dart';
import '../../../services/organization.service.dart';
import '../../../services/customer_storage.service.dart';
import '../../stage/stage.view.dart';
import '../create_or_edit_org/update_employee_profile.view.dart';

class ProfileViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _organizationService = locator<OrganizationService>();
  final _employeeProfileService = locator<EmployeeProfileService>();
  final _authService = locator<AuthService>();
  final _customerStorageService = locator<CustomerStorageService>();

  final _user = ReactiveValue(getUser());
  User get user => _user.value;

  final _organization = ReactiveValue<Organization?>(null);
  Organization? get organization => _organization.value;

  final _employeeProfile = ReactiveValue<Employee?>(null);
  Employee? get employeeProfile => _employeeProfile.value;

  final _customer = ReactiveValue<Customer?>(null);
  Customer? get customer => _customer.value;

  final _isLoading = ReactiveValue<bool>(false);
  bool get isLoading => _isLoading.value;

  void init() {
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    _isLoading.value = true;
    notifyListeners();

    // Refresh user data from local storage first
    _user.value = getUser();
    notifyListeners();

    // Load customer data from local storage first
    _customer.value = _customerStorageService.getStoredCustomer();
    notifyListeners();

    // Fetch customer data from API only if user role is processor
    if (getUser().primaryRole == UserRole.processor && getUser().id != null) {
      try {
        final customer = await _customerStorageService.fetchAndStoreCustomer(
          getUser().id!,
        );
        if (customer != null) {
          _customer.value = customer;
          notifyListeners();
        }
      } catch (e) {
        // Silent error handling for background refresh
        print('Error fetching customer data: $e');
      }
    }

    // Fetch organization profile
    try {
      if (getUser().userType == UserType.employee) {
        final response = await _employeeProfileService.getProfile();
        response.fold(
          (exception) {
            // Just log the error, don't show toast since this is background refresh
            // User might already be seeing other content
          },
          (emp) {
            _employeeProfile.value = emp;
          },
        );
      } else {
        final response = await _organizationService.getProfile();

        response.fold(
          (exception) {
            // Just log the error, don't show toast since this is background refresh
            // User might already be seeing other content
          },
          (org) {
            _organization.value = org;
          },
        );
      }
    } catch (e) {
      // Silent error handling for background refresh
    } finally {
      _isLoading.value = false;
      notifyListeners();
    }
  }

  void navigateToQRView() async {
    await _navigationService.navigateTo(Routes.qr);
  }

  void navigateToCreateOrEditOrgView() async {
    final result = await _navigationService.navigateTo(
      Routes.updateOrg,
      arguments: UpdateOrganizationViewAttributes(organization: organization),
    );

    if (result == true) {
      fetchUserProfile();
    } else {
      fetchUserProfile();
    }
  }

  void onBackPress() async {
    await _navigationService.clearStackAndShow(
      Routes.stage,
      arguments: StageViewAttributes(selectedBottomNavIndex: 0),
    );
  }

  void navigateToEmployeeProfileView() async {
    final result = await _navigationService.navigateTo(
      Routes.updateEmployee,
      arguments: EmployeeProfileViewAttributes(employee: employeeProfile),
    );

    // Refresh profile when returning from edit screen
    if (result == true) {
      fetchUserProfile();
    } else {
      // Even if the user didn't explicitly save, refresh data
      // to ensure consistency
      fetchUserProfile();
    }
  }

  void navigateToLoginView() async {
    User? currentUser = getUser();

    if (currentUser.email != null) {
      await AccountManagerService.instance.saveCurrentUser(currentUser);
    }

    String? fcmToken = getUser().fcmToken;
    _authService.logout(fcmToken);
  }

  void navigateToGeneralSetting() async {
    await _navigationService.navigateTo(Routes.generalSetting);
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [];
}
