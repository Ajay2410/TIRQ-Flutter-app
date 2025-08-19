
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:manager/core/models/employee.dart';
import 'package:manager/core/models/organization.dart';
import 'package:manager/core/utils/app_logger.dart';
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
import '../../stage/stage.view.dart';
import '../create_or_edit_org/update_employee_profile.view.dart';

class ProfileViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _organizationService = locator<OrganizationService>();
  final _employeeProfileService = locator<EmployeeProfileService>();
  final _authService = locator<AuthService>();

  final _user = ReactiveValue(getUser());
  User get user => _user.value;

  final _organization = ReactiveValue<Organization?>(null);
  Organization? get organization => _organization.value;

  final _employeeProfile = ReactiveValue<Employee?>(null);
  Employee? get employeeProfile => _employeeProfile.value;

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
    // Fetch organization profile
    try {
      if(getUser().userType == UserType.employee){

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

      }
      else {
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
    await _authService.logout(fcmToken);

    try {
      final userBox = await Hive.openBox<User>('user');
      await userBox.clear();
    } catch (e) {
      AppLogger.error('Error clearing user data: $e');
    }

    await _navigationService.clearStackAndShow(Routes.login);
    Fluttertoast.showToast(msg: 'Logged out successfully!');
  }

  void navigateToGeneralSetting() async {
    await _navigationService.navigateTo(Routes.generalSetting);
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [];


}
