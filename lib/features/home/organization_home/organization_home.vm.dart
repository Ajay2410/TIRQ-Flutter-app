import 'package:flutter/material.dart';
import 'package:manager/core/models/dashboard.dart';
import 'package:manager/core/models/hive/user/user.dart';
import 'package:manager/core/models/widgets/home/home_card_model.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/services/dashboard.service.dart';
import 'package:manager/services/organization.service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/utils/helpers/helpers.dart';
import '../../../routes/routes.dart';
import '../../../services/auth.service.dart';
import '../../../services/bottom_sheets.service.dart';
import '../../../services/notification.service.dart';
import '../../../widgets/bottom_sheets/qr_scan/qr_scan_sheet.view.dart';
import '../../employee/add_employee/add_employee.view.dart';
import '../../organization/add_partner/add_partner.view.dart';

class OrganizationHomeViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final organizationService = locator<OrganizationService>();
  final _dashboardService = locator<DashboardService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _authService = locator<AuthService>();

  final _user = ReactiveValue(getUser());
  User get user => _user.value;

  final ReactiveValue<Dashboard?> _dashboard = ReactiveValue(null);
  Dashboard? get dashboard => _dashboard.value;

  // Added to access dashboard stats
  DashboardStats? get stats => _dashboard.value?.stats;

  final ReactiveValue<bool> _isLoading = ReactiveValue(false);
  bool get isLoading => _isLoading.value;

  void init() {
    requestPermissions();
    // fetchDashboardData();
    initNotifications();
  }

  initNotifications() async {
    final oldToken = getUser().fcmToken;
    final newToken = await NotificationService().getToken();

    if (newToken != null) {
      await _authService.updateFcmToken(token: newToken, oldToken: oldToken);
      await saveUser(getUser().copyWith(fcmToken: newToken));
    }
  }

  Future<void> fetchDashboardData() async {
    _isLoading.value = true;
    final result = await _dashboardService.getDashboardData();
    result.fold(
      (failure) {
        // Handle error - could show a snackbar or other error indication
        print('Failed to load dashboard: ${failure.message}');
      },
      (dashboardData) {
        _dashboard.value = dashboardData;
      },
    );

    _isLoading.value = false;
    notifyListeners();
  }

  void navigateToRoute(
    String route,
    dynamic arguments, {
    Map<String, String>? parameters,
  }) async {
    await _navigationService.navigateTo(
      route,
      arguments: arguments,
      parameters: parameters,
    );
  }

  void navigateToCustomersList() async {
    _navigationService.navigateTo(Routes.customersList);
  }

  void navigateToAnalytics() async {
    _navigationService.navigateTo(Routes.analytics);
  }

  void navigateToFeedback() async {
    _navigationService.navigateTo(Routes.feedback);
  }

  void navigateToInvoice() async {
    _navigationService.navigateTo(Routes.invoice);
  }

  void navigateToGlobalActivity() async {
    _navigationService.navigateTo(Routes.globalActivity);
  }

  void navigateToWarrantyTracker() async {
    _navigationService.navigateTo(Routes.warranty);
  }

  void navigateToInstallationTracker() async {
    _navigationService.navigateTo(Routes.installation);
  }

  void navigateToMachineRecords() async {
    _navigationService.navigateTo(Routes.machineRecords);
  }

  // Add these new route navigation methods for the quick action menu
  void showQuickActionMenu(BuildContext context) {
    // This method is called by the floating action button
    // Implementation is in the QuickActionMenu widget
  }

  // Convert DashboardCard to HomeCardModel for UI compatibility
  HomeCardModel dashboardCardToHomeCard(DashboardCard card) {
    // Get color value - API now returns an integer directly
    int colorValue = 0xFF72B6B6; // Default color

    if (card.colorCode is int) {
      // API is now returning an integer directly
      colorValue = card.colorCode as int;
    } else if (card.colorCode is String) {
      // For backward compatibility, handle string format if needed
      try {
        final colorCode =
            (card.colorCode as String).startsWith('#')
                ? (card.colorCode as String).substring(1)
                : card.colorCode as String;

        colorValue = int.parse(
          colorCode.length == 6 ? '0xFF$colorCode' : '0x$colorCode',
          radix: 16,
        );
      } catch (e) {
        print('Error parsing color code: ${card.colorCode}');
      }
    }

    // Determine icon data based on card id or use a default
    IconData iconData = Icons.dashboard;

    switch (card.id.toLowerCase()) {
      case 'teams':
        iconData = Icons.people;
        break;
      case 'machines':
        iconData = Icons.precision_manufacturing;
        break;
      case 'tickets':
        iconData = Icons.confirmation_number;
        break;
      case 'attendance':
        iconData = Icons.calendar_today;
        break;
      case 'tasks':
        iconData = Icons.assignment;
        break;
      case 'reporting':
        iconData = Icons.analytics;
        break;
      default:
        iconData = Icons.dashboard;
    }

    // Create a HomeCardModel from the DashboardCard
    return HomeCardModel(
      id: card.id,
      title: card.title,
      description: card.description,
      route: card.route,
      colorCode: colorValue,
      iconData: iconData,
      iconUrl: card.iconUrl,
      imageUrl: card.imageUrl.isNotEmpty ? card.imageUrl : card.iconUrl,
    );
  }

  showScanQrOptionsForEmployee() async {
    final response = await _bottomSheetService
        .showCustomSheet<QrScanSheetResponse, QrScanSheetAttributes>(
          variant: BottomSheetType.qrScan,
          data: QrScanSheetAttributes(),
          isScrollControlled: true,
        );
    if (response?.confirmed == true) {
      await Future.delayed(Duration.zero);
      if (response?.data?.qrSource == QrSource.gallery) {
        navigateToScanQRFromGallery(
          (data) => navigateToAddEmployee(data as String),
        );
      }
      if (response?.data?.qrSource == QrSource.camera) {
        navigateToScanQRFromCamera(
          (data) => navigateToAddEmployee(data as String),
        );
      }
    }
  }

  void navigateToAddEmployee(String id) async {
    await _navigationService.navigateTo(
      Routes.addEmployee,
      arguments: AddEmployeeViewAttributes(id: id),
    );
  }

  showScanQrOptionsForPartner() async {
    final response = await _bottomSheetService
        .showCustomSheet<QrScanSheetResponse, QrScanSheetAttributes>(
          variant: BottomSheetType.qrScan,
          data: QrScanSheetAttributes(),
          isScrollControlled: true,
        );
    if (response?.confirmed == true) {
      await Future.delayed(Duration());
      if (response?.data?.qrSource == QrSource.gallery) {
        navigateToScanQRFromGallery(
          (data) => navigateToAddPartner(data as String),
        );
      }
      if (response?.data?.qrSource == QrSource.camera) {
        navigateToScanQRFromCamera(
          (data) => navigateToAddPartner(data as String),
        );
      }
    }
  }

  Future<void> requestPermissions() async {
    try {
      await Permission.notification.request();
      await Permission.camera.request();
      await Permission.storage.request();
      await Permission.microphone.request();
      await Permission.photos.request();
    } catch (e) {
      AppLogger.error(e);
    }
  }

  void navigateToAddPartner(String id) async {
    await _navigationService.navigateTo(
      Routes.addPartner,
      arguments: AddPartnerViewAttributes(id: id),
    );
  }
}
