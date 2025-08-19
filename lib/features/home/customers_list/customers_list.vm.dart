import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/core/models/hive/user/user.dart';
import 'package:manager/core/models/relationships.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/features/organization/add_partner/add_partner.view.dart';
import 'package:manager/features/search/search_view.dart';
import 'package:manager/services/dialogs.service.dart';
import 'package:manager/services/file_picker.service.dart';
import 'package:manager/services/organization.service.dart';
import 'package:manager/widgets/dialogs/relationship_request/relationship_request_dialog.view.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/helpers/helpers.dart';
import '../../../routes/routes.dart';
import '../../../services/bottom_sheets.service.dart';
import '../../../widgets/bottom_sheets/qr_scan/qr_scan_sheet.view.dart';
import '../../machines/machines_list/machines_list.view.dart';
import '../../stage/stage.view.dart';

class CustomersListViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final organizationService = locator<OrganizationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _filePickerService = FilePickerService();

  // Reactive values
  final ReactiveValue<List<Relationship>> _relationshipsList =
      ReactiveValue<List<Relationship>>([]);
  final ReactiveValue<List<Relationship>> _filteredRelationships =
      ReactiveValue<List<Relationship>>([]);
  final ReactiveValue<String> _searchQuery = ReactiveValue<String>('');
  final ReactiveValue<String> _selectedStatus = ReactiveValue<String>('All');

  // Getters
  List<Relationship> get relationshipsList => _relationshipsList.value;
  List<Relationship> get filteredRelationships => _filteredRelationships.value;
  String get searchQuery => _searchQuery.value;
  String get selectedStatus => _selectedStatus.value;

  // Setters
  set searchQuery(String value) {
    _searchQuery.value = value;
    _applyFilters();
    notifyListeners();
  }

  void init() {
    getPartners(status: _selectedStatus.value);
  }

  Future<void> getPartners({String? status}) async {
    setBusy(true);
    final response = await organizationService.getPartners(status: status);
    setBusy(false);
    response.fold(
      (exception) {
        Fluttertoast.showToast(msg: exception.message.toString());
        _relationshipsList.value = [];
        _filteredRelationships.value = [];
      },
      (partners) {
        _relationshipsList.value = partners;
        _applyFilters();
      },
    );
  }

  void _applyFilters() {
    if (_searchQuery.value.isEmpty) {
      _filteredRelationships.value = [..._relationshipsList.value];
    } else {
      final query = _searchQuery.value.toLowerCase();
      _filteredRelationships.value =
          _relationshipsList.value.where((relationship) {
            final nameMatch =
                relationship.partnerName?.toLowerCase().contains(query) ??
                false;
            final idMatch =
                relationship.relationshipId?.toLowerCase().contains(query) ??
                false;

            return nameMatch || idMatch;
          }).toList();
    }
    notifyListeners();
  }

  void updateSelectedStatus(String status) {
    if (_selectedStatus.value != status) {
      _selectedStatus.value = status;
      getPartners(status: status);
    }
  }

  Future<void> refreshCustomers() async {
    return getPartners(status: _selectedStatus.value);
  }

  void onCustomerTap(Relationship relationship) {
    // if (relationship.requesterId == getUser().id && relationship.status == RelationshipStatus.pending ) {
    //   return;
    // }
    if (relationship.status == RelationshipStatus.pending && getUser().organizationType == OrganizationType.manufacturer) {
      showRelationshipRequestDialog(relationship);
    } else {
      // Navigate to Machines List for the specific partner
      _navigationService.navigateTo(
        Routes.machinesList,
        parameters: MachinesListViewAttributes(
          processorId: relationship.partnerId??'',
          organizationId: relationship.requesterId??'',
          title: relationship.partnerName ?? 'Partner Machines',
          showAddButton: relationship.partnerId!=null,
          showFilterButton: true,
        ).toJson(),
      );
    }
  }

  void showRelationshipRequestDialog(Relationship relationship) {
    _dialogService.showCustomDialog(
      variant: DialogType.relationshipRequest,
      data: RelationshipRequestDialogAttributes(
        relationship: relationship,
        onDeclineRequest: () {
          declineRequest(relationship.relationshipId!);
        },
        onAcceptRequest: () {
          acceptRequest(relationship.relationshipId!);
        },
      ),
    );
  }

  void acceptRequest(String relationshipId) async {
    final response = await organizationService.acceptRequest(
      relationshipId: relationshipId,
    );
    response.fold(
      (exception) {
        Fluttertoast.showToast(msg: exception.message.toString());
      },
      (isAccepted) async {
        Fluttertoast.showToast(msg: 'Request accepted successfully!');
        // Refresh the list
        getPartners(status: _selectedStatus.value);
      },
    );
  }

  void declineRequest(String relationshipId) async {
    final response = await organizationService.declineRequest(
      relationshipId: relationshipId,
    );
    response.fold(
      (exception) {
        Fluttertoast.showToast(msg: exception.message.toString());
      },
      (isDeclined) async {
        Fluttertoast.showToast(msg: 'Request declined successfully!');
        // Refresh the list
        getPartners(status: _selectedStatus.value);
      },
    );
  }

  showScanQrOptions() async {
    final response = await _bottomSheetService
        .showCustomSheet<QrScanSheetResponse, QrScanSheetAttributes>(
          variant: BottomSheetType.qrScan,
          data: QrScanSheetAttributes(),
          isScrollControlled: true,
        );
    if (response?.confirmed == true) {
      setBusy(true);
      if (response?.data?.qrSource == QrSource.gallery) {
        await _scanQRFromGallery(
          (data) => navigateToAddPartner(AddPartnerViewAttributes(id:data as String)),
        );
      }
      if (response?.data?.qrSource == QrSource.camera) {
        navigateToScanQRFromCamera(
          (data) => navigateToAddPartner(AddPartnerViewAttributes(id:data as String)),
        );
      }
      if ([
        QrSource.phoneNumber,
        QrSource.email,
      ].contains(response?.data?.qrSource)) {
        navigateToSearch(
          SearchViewAttributes(
            title: 'organization',
            apiEndPoint: 'org/search',
            onSelect: (data) {
               _navigationService.back();
              navigateToAddPartner(AddPartnerViewAttributes(id:data as String));
            },
          ),
        );
      }
      if ([
        QrSource.addNew,
      ].contains(response?.data?.qrSource)) {
        navigateToAddPartner(
          AddPartnerViewAttributes(
            id: null,
            hasPasswordField: true,
            hasReadOnly: false,
          ),
        );
      }
      setBusy(false);
    }
  }

  Future<void> _scanQRFromGallery(Function(dynamic) onScanQr) async {
    try {
      // Use FilePickerService to pick image from gallery
      final result = await _filePickerService.pickImageFromGallery();

      result.fold(
        (failure) {
          // Handle failure
          Fluttertoast.showToast(msg: failure.message);
        },
        (imageFile) async {
          try {
            final MobileScannerController controller =
                MobileScannerController();
            final result = await controller.analyzeImage(imageFile.path);
            if (result == null ||
                result.barcodes.isEmpty ||
                result.barcodes.first.rawValue == null) {
              Fluttertoast.showToast(msg: 'Could not scan the image');
            } else {
              await onScanQr(result.barcodes.first.rawValue);
            }
          } catch (e) {
            AppLogger.error(e);
            Fluttertoast.showToast(msg: "No QR found in image");
          }
        },
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error scanning QR code: ${e.toString()}');
    }
  }

  void navigateToAddPartner(AddPartnerViewAttributes attributes) async {
    await _navigationService.navigateTo(
      Routes.addPartner,
      arguments: attributes,
    );
    // Refresh the employee list after returning
    getPartners(status: _selectedStatus.value);
  }
}
