import 'package:manager/core/models/employee.dart';
import 'package:manager/core/models/organization.dart';
import 'package:manager/core/models/customer.dart';
import 'package:manager/features/profile/create_or_edit_org/create_or_edit_org.view.dart';
import 'package:manager/routes/routes.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/models/hive/user/user.dart' as hive_user;
import '../../../core/models/profile_model.dart';
import '../../../core/storage/storage.dart';
import '../../../services/account.service.dart';
import '../../../services/auth.service.dart';
import '../../../services/customer_storage.service.dart';
import '../../stage/stage.view.dart';
import '../../../services/profile.service.dart';

class ProfileViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _authService = locator<AuthService>();
  final _customerStorageService = locator<CustomerStorageService>();
  final _profileService = locator<ProfileService>();

  final _user = ReactiveValue(getUser());
  hive_user.User get user => _user.value;

  final _organization = ReactiveValue<Organization?>(null);
  Organization? get organization => _organization.value;

  final _employeeProfile = ReactiveValue<Employee?>(null);
  Employee? get employeeProfile => _employeeProfile.value;

  final _customer = ReactiveValue<Customer?>(null);
  Customer? get customer => _customer.value;

  final _profile = ReactiveValue<ProfileModel?>(null);
  ProfileModel? get profile => _profile.value;

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

    // Clear customer data first to ensure fresh data
    _customer.value = null;
    notifyListeners();

    // Load customer data from local storage first
    _customer.value = _customerStorageService.getStoredCustomer();
    notifyListeners();

    // Fetch customer data from API only if user role is processor
    if (getUser().primaryRole == hive_user.UserRole.processor &&
        getUser().id != null) {
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

    // Fetch organization profile using the global ProfileService
    try {
      final response = await _profileService.getProfile();
      response.fold(
        (exception) {
          // Just log the error, don't show toast since this is background refresh
          print('Error fetching profile: ${exception.message}');
        },
        (profile) {
          _profile.value = profile;
          notifyListeners();
        },
      );
    } catch (e) {
      // Silent error handling for background refresh
      print('Error fetching profile: $e');
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


  void navigateToLoginView() async {
    hive_user.User? currentUser = getUser();

    if (currentUser.email != null) {
      await AccountManagerService.instance.saveCurrentUser(currentUser);
    }

    // Clear customer data from memory
    _customer.value = null;
    notifyListeners();

    // Clear customer data from storage
    await _customerStorageService.clearCustomerData();

    String? fcmToken = getUser().fcmToken;
    _authService.logout(fcmToken);
  }

  void navigateToGeneralSetting() async {
    await _navigationService.navigateTo(Routes.generalSetting);
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [];
}
