import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/core/models/relationships.dart';
import 'package:manager/services/organization.service.dart';
import 'package:manager/widgets/bottom_sheets/file_picker_options/file_picker_options_sheet.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/models/machine.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/type_def.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../routes/routes.dart';
import '../../../services/bottom_sheets.service.dart';
import '../../../services/chat.service.dart';
import '../../../services/dialogs.service.dart';
import '../../../services/file_picker.service.dart';
import '../../../services/file_upload.service.dart';
import '../../../services/machine.service.dart';
import '../../../services/ticket.service.dart';
import '../../../widgets/dialogs/loader/loader_dialog.view.dart';
import '../../Messages/chat/chat.view.dart';
import '../../machines/add_machine/add_machine.view.dart';

// Additional Info Section class for tickets
class AdditionalInfoSection {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  AdditionalInfoSection({
    required this.titleController,
    required this.descriptionController,
  });
}

// Enum for maintenance types
enum MaintenanceType { generalCheckup, fullMachineService }

class AddTicketViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _ticketService = locator<TicketService>();
  final _organizationService = locator<OrganizationService>();
  final _filePickerService = FilePickerService();
  final _fileUploadService = FileUploadService();
  final _machineService = locator<MachineService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _dialogService = locator<DialogService>();
  final _chatService = locator<ChatService>();

  final formKey = GlobalKey<FormState>();
  final TextEditingController problemController = TextEditingController();
  final TextEditingController errorCodeController = TextEditingController();
  final TextEditingController additionalNoteController =
      TextEditingController();

  // Additional info sections list
  final List<AdditionalInfoSection> _additionalInfoSections = [];
  List<AdditionalInfoSection> get additionalInfoSections =>
      _additionalInfoSections;

  Machine? _machine;
  Machine? get machine => _machine;

  Relationship? _relationship;
  Relationship? get relationship => _relationship;

  // For machine selection dropdown
  final ReactiveValue<List<Machine>> _availableMachines =
      ReactiveValue<List<Machine>>([]);
  List<Machine> get availableMachines => _availableMachines.value;

  final ReactiveValue<List<Relationship>> _availableRelationships =
      ReactiveValue<List<Relationship>>([]);
  List<Relationship> get availableRelationships =>
      _availableRelationships.value;

  final ReactiveValue<bool> _isLoadingMachines = ReactiveValue<bool>(false);
  bool get isLoadingMachines => _isLoadingMachines.value;

  final ReactiveValue<bool> _isLoadingRelationships = ReactiveValue<bool>(
    false,
  );
  bool get isLoadingRelationships => _isLoadingRelationships.value;

  bool _isFormValid = false;
  bool get isFormValid => _isFormValid;

  bool _didChange = false;
  bool get didChange => _didChange;

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  // Stores local files for upload
  final List<File> _localFiles = [];
  List<File> get localFiles => _localFiles;

  // Stores already uploaded file URLs
  final List<String> _attachments = [];
  List<String> get attachments => _attachments;

  String _ticketType = "Repair";
  String get ticketType => _ticketType;

  // Maintenance type selection
  MaintenanceType? _selectedMaintenanceType;
  MaintenanceType? get selectedMaintenanceType => _selectedMaintenanceType;

  // For file upload status
  final ReactiveValue<bool> _isUploading = ReactiveValue<bool>(false);
  bool get isUploading => _isUploading.value;

  final ReactiveValue<double> _uploadProgress = ReactiveValue<double>(0.0);
  double get uploadProgress => _uploadProgress.value;

  set isEditing(bool value) {
    _isEditing = value;
    notifyListeners();
  }

  static const int MAX_IMAGES = 5;
  static const int MAX_VIDEOS = 1;

  // Helper method to count current attachments by type
  int get currentImageCount {
    return attachments.where((attachment) => _isImage(attachment.file)).length;
  }

  int get currentVideoCount {
    return attachments.where((attachment) => _isVideo(attachment.file)).length;
  }

  bool _isImage(File file) {
    final extension = file.path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  bool _isVideo(File file) {
    final extension = file.path.toLowerCase().split('.').last;
    return [
      'mp4',
      'avi',
      'mov',
      'wmv',
      'flv',
      '3gp',
      'mkv',
    ].contains(extension);
  }

  // Check if machine warranty is active
  bool get isMachineWarrantyActive {
    if (_machine?.warranty == null) return false;

    String status = _machine!.warranty?.status?.toLowerCase() ?? '';

    // Safely handle the expiration date parsing
    DateTime? expirationDate;
    if (_machine!.warranty?.expirationDate != null) {
      try {
        expirationDate = DateTime.parse(_machine!.warranty!.expirationDate!);
      } catch (e) {
        return false; // Invalid date format
      }
    }

    return status == 'active' &&
        expirationDate != null &&
        DateTime.now().isBefore(expirationDate);
  }

  // Get warranty message based on selection
  String get warrantyMessage {
    if (_ticketType != "Maintenance" || _selectedMaintenanceType == null) {
      return "";
    }

    if (isMachineWarrantyActive) {
      if (_selectedMaintenanceType == MaintenanceType.generalCheckup) {
        return "Your machine is under warranty, and you've selected a General Checkup. Travel, food, and accommodation will be arranged in advance. There will be no service charge.";
      } else {
        return "Your machine is under warranty, and you've selected Full Machine Service. Travel, food, and accommodation will be arranged in advance. A service charge of 50 USD will apply.";
      }
    } else {
      return "Your machine is out of warranty. Travel, food, and accommodation will be arranged in advance. A service charge of 100 USD will apply.";
    }
  }

  // Check if payment is required
  bool get requiresPayment {
    if (_ticketType != "Maintenance" || _selectedMaintenanceType == null) {
      return false;
    }

    if (isMachineWarrantyActive) {
      return _selectedMaintenanceType == MaintenanceType.fullMachineService;
    } else {
      return true; // Out of warranty always requires payment
    }
  }

  // Get service charge amount
  double get serviceCharge {
    if (_ticketType != "Maintenance" || _selectedMaintenanceType == null) {
      return 0.0;
    }

    if (isMachineWarrantyActive) {
      return _selectedMaintenanceType == MaintenanceType.fullMachineService
          ? 50.0
          : 0.0;
    } else {
      return 100.0; // Out of warranty charge
    }
  }

  void init(Machine? machine) {
    _machine = machine;

    if (machine != null) {
      _isEditing = true;
    }

    problemController.addListener(_updateFormValidity);
    errorCodeController.addListener(_updateFormValidity);
    additionalNoteController.addListener(_updateFormValidity);

    if (machine == null) {
      loadAvailableRelationships();
    }
  }

  void addNewInfoSection() {
    _additionalInfoSections.add(
      AdditionalInfoSection(
        titleController: TextEditingController(),
        descriptionController: TextEditingController(),
      ),
    );
    notifyListeners();
    _updateFormValidity();
  }

  void removeInfoSection(int index) {
    if (index >= 0 && index < _additionalInfoSections.length) {
      _additionalInfoSections.removeAt(index);
      notifyListeners();
      _updateFormValidity();
    }
  }

  void navigateToImageView(String imageUrl) async {
    _navigationService.navigateTo(Routes.imageViewerView, arguments: imageUrl);
  }

  Future<void> loadAvailableMachines() async {
    if (_relationship == null) {
      return;
    }
    _isLoadingMachines.value = true;
    notifyListeners();

    final result = await _machineService.getMachines(
      status: '',
      department: '',
      manufacturerId: _relationship!.requesterId!,
      processorId: _relationship!.partnerId!,
    );

    result.fold(
      (failure) {
        AppLogger.error("Failed to load machines: ${failure.message}");
        Fluttertoast.showToast(
          msg: "Failed to load machines: ${failure.message}",
          backgroundColor: Colors.red,
        );
      },
      (machinesListInfo) {
        _availableMachines.value = machinesListInfo.machines;
        notifyListeners();
      },
    );

    _isLoadingMachines.value = false;
    notifyListeners();
  }

  Future<void> loadAvailableRelationships() async {
    _isLoadingRelationships.value = true;
    notifyListeners();

    final result = await _organizationService.getPartners(status: 'active');

    result.fold(
      (failure) {
        AppLogger.error("Failed to load relationships: ${failure.message}");
        Fluttertoast.showToast(
          msg: "Failed to load relationships: ${failure.message}",
          backgroundColor: Colors.red,
        );
      },
      (relationships) {
        _availableRelationships.value = relationships;
        notifyListeners();
      },
    );

    _isLoadingRelationships.value = false;
    notifyListeners();
  }

  void selectMachine(Machine? selectedMachine) {
    _machine = selectedMachine;
    notifyListeners();
    _updateFormValidity();
  }

  void selectRelationship(Relationship? selectedRelationship) {
    _relationship = selectedRelationship;
    notifyListeners();
    _updateFormValidity();
    _machine = null;
    _availableMachines.value.clear();
    loadAvailableMachines();
  }

  void setTicketType(String value) {
    _ticketType = value;
    // Reset maintenance type when changing ticket type
    if (value != "Maintenance") {
      _selectedMaintenanceType = null;
    }
    notifyListeners();
    _updateFormValidity();
  }

  void setMaintenanceType(MaintenanceType? type) {
    _selectedMaintenanceType = type;
    notifyListeners();
    _updateFormValidity();
  }

  void _updateFormValidity() {
    bool isValid = _machine != null;

    // For maintenance tickets, also require maintenance type selection
    if (_ticketType == "Maintenance") {
      isValid = isValid && _selectedMaintenanceType != null;
    }

    // Always require problem description
    isValid = isValid && problemController.text.isNotEmpty;

    if (_isFormValid != isValid) {
      _isFormValid = isValid;
      notifyListeners();
    }

    if (!_didChange) {
      _didChange = true;
      notifyListeners();
    }
  }

  Future<void> _uploadAttachments() async {
    if (_localFiles.isEmpty) return;

    _isUploading.value = true;
    _uploadProgress.value = 0.0;
    notifyListeners();

    for (int i = 0; i < _localFiles.length; i++) {
      final result = await _fileUploadService.uploadFileWithProgress(
        _localFiles[i],
        (progress) {
          final singleFileContribution = 1.0 / _localFiles.length;
          _uploadProgress.value =
              (i * singleFileContribution) +
              (progress * singleFileContribution);
          notifyListeners();
        },
      );

      result.fold(
        (failure) {
          AppLogger.error('Failed to upload file: ${failure.message}');
          Fluttertoast.showToast(
            msg: 'Failed to upload file: ${failure.message}',
            backgroundColor: Colors.red,
          );
        },
        (url) {
          _attachments.add(url);
          notifyListeners();
        },
      );
    }

    _localFiles.clear();
    _isUploading.value = false;
    _uploadProgress.value = 1.0;
    notifyListeners();
  }

  void onSave() async {
    if (!isFormValid) {
      if (_machine == null) {
        Fluttertoast.showToast(
          msg: "Please select a machine",
          backgroundColor: Colors.red,
        );
      } else if (_ticketType == "Maintenance" &&
          _selectedMaintenanceType == null) {
        Fluttertoast.showToast(
          msg: "Please select a maintenance type",
          backgroundColor: Colors.red,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Please describe the problem",
          backgroundColor: Colors.red,
        );
      }
      return;
    }

    // For maintenance tickets that require payment, navigate to payment first
    if (_ticketType == "Maintenance" && requiresPayment) {
      _navigateToPayment();
      return;
    }

    // Otherwise proceed with ticket creation
    await _createTicket();
  }

  void _navigateToPayment() {
    // TODO: Implement navigation to payment page
    // Pass service charge amount and other details
    AppLogger.info(
      "Navigate to payment with charge: \$${serviceCharge.toStringAsFixed(2)}",
    );

    // For now, show a placeholder message
    Fluttertoast.showToast(
      msg: "Proceeding to payment: \$${serviceCharge.toStringAsFixed(2)}",
      backgroundColor: Colors.blue,
    );

    // After payment is successful, call _createTicket()
    // For demo purposes, we'll create the ticket directly
    _createTicket();
  }

  Future<void> _createTicket() async {
    setBusy(true);

    if (_localFiles.isNotEmpty) {
      await _uploadAttachments();
    }

    List<Map<String, dynamic>> additionalInfo = [];
    for (var section in _additionalInfoSections) {
      if (section.titleController.text.isNotEmpty ||
          section.descriptionController.text.isNotEmpty) {
        additionalInfo.add({
          'title': section.titleController.text.trim(),
          'description': section.descriptionController.text.trim(),
        });
      }
    }

    // Build the full description with maintenance type info
    String fullDescription = problemController.text;

    if (_ticketType == "Maintenance" && _selectedMaintenanceType != null) {
      String maintenanceTypeText =
          _selectedMaintenanceType == MaintenanceType.generalCheckup
              ? "General Checkup"
              : "Full Machine Service";
      fullDescription =
          "Maintenance Type: $maintenanceTypeText\n\n$fullDescription";
    }

    if (errorCodeController.text.isNotEmpty) {
      fullDescription += '\n\nError Code: ${errorCodeController.text}';
    }

    if (additionalNoteController.text.isNotEmpty) {
      fullDescription +=
          '\n\nAdditional Notes: ${additionalNoteController.text}';
    }

    final result = await _ticketService.createTicket(
      machineId: _machine!.id!,
      title: problemController.text.trim(),
      description: fullDescription.trim(),
      ticketType: ticketType,
      attachments: attachments.isNotEmpty ? attachments : null,
      additionalInfo: additionalInfo.isNotEmpty ? additionalInfo : null,
    );

    setBusy(false);

    result.fold(
      (failure) {
        AppLogger.error("Failed to create ticket: ${failure.message}");
        Fluttertoast.showToast(
          msg: "Failed to create ticket: ${failure.message}",
          backgroundColor: Colors.red,
        );
      },
      (ticketId) {
        AppLogger.info("Ticket created successfully!");
        Fluttertoast.showToast(
          msg: "Ticket created successfully!",
          backgroundColor: Colors.green,
        );
        navigateToChatView(ticketId);
        _navigationService.back();
      },
    );
  }

  void navigateToChatView(String ticketId) async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(
        task:
            () =>
                _chatService.getChatViewAttributesForTicket(ticketId: ticketId),
        message: "Loading chat...",
      ),
    );
    if (response?.data != null) {
      (response!.data as EitherResult<ChatViewAttributes>).fold(
        (failure) {
          AppLogger.error(failure.message);
          Fluttertoast.showToast(msg: failure.message);
        },
        (attributes) {
          _navigationService.navigateTo(Routes.chat, arguments: attributes);
        },
      );
    }
  }

  void addLocalFile(File file) {
    _localFiles.add(file);
    notifyListeners();
    _updateFormValidity();
  }

  void removeLocalFile(int index) {
    if (index >= 0 && index < _localFiles.length) {
      _localFiles.removeAt(index);
      notifyListeners();
    }
  }

  void removeAttachment(String url) {
    _attachments.remove(url);
    notifyListeners();
  }

  Future<void> uploadImages() async {
    if (attachments.length > 6) {
      Fluttertoast.showToast(
        msg: 'Maximum 6 attachments allowed',
        backgroundColor: Colors.red,
      );
      return;
    }
    await showImagePickerOptions();
  }

  Future<void> showImagePickerOptions() async {
    final result = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.filePickerOptions,
      data: FilePickerOptionsSheetAttributes(),
      title: 'Add Attachment',
      description: 'Choose an option',
      mainButtonTitle: 'Cancel',
    );

    if (result?.confirmed == true) {
      final option = result?.data;
      if (option == 'camera') {
        await takePhoto();
      } else if (option == 'gallery') {
        await pickGalleryImage();
      } else if (option == 'video_gallery') {
        await pickGalleryVideo();
      } else if (option == 'video_camera') {
        await recordVideo();
      } else if (option == 'document') {
        await pickDocument();
      }
    }
  }

  Future<void> pickGalleryImage() async {
    if (currentImageCount >= MAX_IMAGES) {
      Fluttertoast.showToast(
        msg: 'Maximum $MAX_IMAGES images allowed',
        backgroundColor: Colors.red,
      );
      return;
    }

    final pickerResult = await _filePickerService.pickMultipleImages();

    pickerResult.fold(
      (failure) {
        if (failure.message != 'No images selected') {
          Fluttertoast.showToast(
            msg: failure.message,
            backgroundColor: Colors.red,
          );
        }
      },
      (files) {
        final remainingSlots = MAX_IMAGES - currentImageCount;
        final filesToAdd = files.take(remainingSlots).toList();

        if (files.length > remainingSlots) {
          Fluttertoast.showToast(
            msg: 'Only $remainingSlots more images can be added',
            backgroundColor: Colors.orange,
          );
        }

        for (final file in filesToAdd) {
          addLocalFile(file);
        }
      },
    );
  }

  Future<void> takePhoto() async {
    if (currentImageCount >= MAX_IMAGES) {
      Fluttertoast.showToast(
        msg: 'Maximum $MAX_IMAGES images allowed',
        backgroundColor: Colors.red,
      );
      return;
    }

    final pickerResult = await _filePickerService.takePhoto(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );

    pickerResult.fold(
      (failure) {
        if (failure.message != 'No photo taken') {
          Fluttertoast.showToast(
            msg: failure.message,
            backgroundColor: Colors.red,
          );
        }
      },
      (file) {
        addLocalFile(file);
      },
    );
  }

  Future<void> pickGalleryVideo() async {
    if (currentVideoCount >= MAX_VIDEOS) {
      Fluttertoast.showToast(
        msg: 'Maximum $MAX_VIDEOS video allowed',
        backgroundColor: Colors.red,
      );
      return;
    }

    final pickerResult = await _filePickerService.pickVideoFromGallery(
      maxDuration: Duration(minutes: 5),
    );

    pickerResult.fold(
      (failure) {
        if (failure.message != 'No video selected') {
          Fluttertoast.showToast(
            msg: failure.message,
            backgroundColor: Colors.red,
          );
        }
      },
      (file) {
        addLocalFile(file);
      },
    );
  }

  Future<void> recordVideo() async {
    if (currentVideoCount >= MAX_VIDEOS) {
      Fluttertoast.showToast(
        msg: 'Maximum $MAX_VIDEOS video allowed',
        backgroundColor: Colors.red,
      );
      return;
    }

    final pickerResult = await _filePickerService.recordVideo(
      maxDuration: Duration(minutes: 5),
    );

    pickerResult.fold(
      (failure) {
        if (failure.message != 'No video recorded') {
          Fluttertoast.showToast(
            msg: failure.message,
            backgroundColor: Colors.red,
          );
        }
      },
      (file) {
        addLocalFile(file);
      },
    );
  }

  Future<void> pickDocument() async {
    if (attachments.length >= 6) {
      Fluttertoast.showToast(
        msg: 'Maximum 6 attachments allowed',
        backgroundColor: Colors.red,
      );
      return;
    }

    final pickerResult = await _filePickerService.pickDocument(
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    pickerResult.fold(
      (failure) {
        if (failure.message != 'No document selected') {
          Fluttertoast.showToast(
            msg: failure.message,
            backgroundColor: Colors.red,
          );
        }
      },
      (file) {
        addLocalFile(file);
      },
    );
  }

  Widget buildAttachmentButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.v14),
        border: Border(
          left: BorderSide(color: AppColors.primary, width: AppSizes.w4),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: isUploading ? null : () => uploadImages(),
                  icon: Icon(Icons.add_photo_alternate),
                  label: Text('Add Media'),
                ),
              ),
            ],
          ),
          if (attachments.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Images: $currentImageCount/$MAX_IMAGES | Videos: $currentVideoCount/$MAX_VIDEOS',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    problemController.dispose();
    errorCodeController.dispose();
    additionalNoteController.dispose();

    for (var section in _additionalInfoSections) {
      section.titleController.dispose();
      section.descriptionController.dispose();
    }
    super.dispose();
  }
}

extension on String {
  File get file => File(this);
}
