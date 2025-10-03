import 'package:get_it/get_it.dart';
import 'package:manager/configs.dart';
import 'package:manager/services/auth.service.dart';
import 'package:manager/services/employee.service.dart';
import 'package:manager/services/machine.service.dart';
import 'package:manager/services/organization.service.dart';
import 'package:manager/services/stage.service.dart';
import 'package:manager/services/ticket.service.dart';
import 'package:manager/services/user.service.dart';
import 'package:stacked_services/stacked_services.dart';

import '../services/account.service.dart';
import '../services/api.service.dart';
import '../services/chat.service.dart';
import '../services/dashboard.service.dart';
import '../services/employee_profile.service.dart';
import '../services/file_picker.service.dart';
import '../services/language.service.dart';
import '../services/machine_storage.service.dart';
import '../services/customer.service.dart';
import '../services/customer_storage.service.dart';

/// **Service Locator Setup**
///
/// This file sets up **dependency injection** using `GetIt`,
/// allowing services to be accessed throughout the app
/// without creating multiple instances.
///
/// ### **Usage**
/// Call `setUpLocators()` in the `main.dart` file before running the app.
///
/// **Example:**
/// ```dart
/// setUpLocators();
/// ```
///
/// Then, retrieve a service anywhere in the app:
/// ```dart
/// final apiService = locator<ApiService>();
/// ```
final GetIt locator = GetIt.instance;

/// **Registers app-wide dependencies**
///
/// This function initializes all the services that
/// should be accessible using `GetIt`.
void setUpLocators() {
  locator.registerLazySingleton(() => Configurations());
  locator.registerLazySingleton(() => ApiService());
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => OrganizationService());
  locator.registerLazySingleton(() => EmployeeService());
  locator.registerLazySingleton(() => MachineService());
  locator.registerLazySingleton(() => TicketService());
  locator.registerLazySingleton(() => ChatService());
  locator.registerLazySingleton(() => SnackbarService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => DashboardService());
  locator.registerLazySingleton(() => StageService());
  locator.registerLazySingleton(() => EmployeeProfileService());
  locator.registerLazySingleton(() => LanguageService());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => AccountManagerService.instance);
  locator.registerLazySingleton(() => MachineStorageService());
  locator.registerLazySingleton(() => CustomerService());
  locator.registerLazySingleton(() => FilePickerService());
  locator.registerLazySingleton(() => CustomerStorageService());
}
