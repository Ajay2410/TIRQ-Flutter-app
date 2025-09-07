import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../core/locator.dart';
import '../../../core/utils/app_logger.dart';
import '../../../services/file_picker.service.dart';
import '../../../widgets/dialogs/create_ticket/create_ticket_dialog.view.dart';

class CreateTicketDialogViewModel extends ReactiveViewModel {
  final _filePickerService = locator<FilePickerService>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController problemController = TextEditingController();
  final TextEditingController errorCodeController = TextEditingController();
  final TextEditingController additionalNotesController =
      TextEditingController();

  final ReactiveValue<bool> _isLoading = ReactiveValue<bool>(false);
  bool get isLoading => _isLoading.value;

  final ReactiveValue<List<File>> _attachments = ReactiveValue<List<File>>([]);
  List<File> get attachments => _attachments.value;

  CreateTicketDialogAttributes? _attributes;

  void init(CreateTicketDialogAttributes attributes) {
    _attributes = attributes;

    // Initialize with provided values
    problemController.text = attributes.initialProblem ?? '';
    errorCodeController.text = attributes.initialErrorCode ?? '';
    additionalNotesController.text = attributes.initialAdditionalNotes ?? '';
    _attachments.value = List.from(attributes.initialAttachments ?? []);

    notifyListeners();
  }

  Future<void> pickMedia() async {
    try {
      // Show options for camera or gallery
      final result = await _filePickerService.pickImageFromGallery(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      result.fold(
        (failure) {
          AppLogger.error('Failed to pick media: ${failure.message}');
          // You could show a toast here if needed
        },
        (file) {
          _attachments.value.add(file);
          notifyListeners();
        },
      );
    } catch (e) {
      AppLogger.error('Error picking media: $e');
    }
  }

  void removeAttachment(int index) {
    if (index >= 0 && index < _attachments.value.length) {
      _attachments.value.removeAt(index);
      notifyListeners();
    }
  }

  void onSubmit() {
    if (formKey.currentState?.validate() ?? false) {
      _attributes?.onSubmit?.call(
        problemController.text.trim(),
        errorCodeController.text.trim(),
        additionalNotesController.text.trim(),
        _attachments.value,
      );
    }
  }

  void onCancel() {
    _attributes?.onCancel?.call();
  }

  @override
  void dispose() {
    problemController.dispose();
    errorCodeController.dispose();
    additionalNotesController.dispose();
    super.dispose();
  }
}
