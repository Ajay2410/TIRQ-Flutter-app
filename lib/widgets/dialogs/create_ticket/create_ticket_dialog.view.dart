import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../../resources/app_resources/app_resources.dart';
import '../../../services/language.service.dart';
import '../../../widgets/common_text_field.dart';
import 'create_ticket_dialog.vm.dart';

class CreateTicketDialogAttributes {
  final String? initialProblem;
  final String? initialErrorCode;
  final String? initialAdditionalNotes;
  final List<File>? initialAttachments;
  final Function(String problem, String errorCode, String additionalNotes, List<File> attachments)? onSubmit;
  final VoidCallback? onCancel;

  CreateTicketDialogAttributes({
    this.initialProblem,
    this.initialErrorCode,
    this.initialAdditionalNotes,
    this.initialAttachments,
    this.onSubmit,
    this.onCancel,
  });
}

class CreateTicketDialog extends StatelessWidget {
  final DialogRequest<CreateTicketDialogAttributes> request;
  final Function(DialogResponse) completer;

  const CreateTicketDialog({super.key, required this.request, required this.completer});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateTicketDialogViewModel>.reactive(
      viewModelBuilder: () => CreateTicketDialogViewModel(),
      onViewModelReady: (viewModel) => viewModel.init(request.data!),
      builder:
          (context, model, child) => Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.v23)),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppSizes.v23)),
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(AppSizes.v16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(AppSizes.v16), topRight: Radius.circular(AppSizes.v16)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LanguageService.get('filled_details'),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.black, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                LanguageService.get('enter_support_request_details'),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop(DialogResponse(confirmed: false));
                            model.onCancel();
                          },
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(AppSizes.v16),
                      child: Form(
                        key: model.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Problem Description
                            CommonTextField(
                              controller: model.problemController,
                              placeholder: LanguageService.get('write_problem_here'),
                              maxLines: 4,
                              validator: CommonValidators.required('Please describe the problem'),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            const SizedBox(height: 16),

                            // Error Code
                            CommonTextField(
                              controller: model.errorCodeController,
                              placeholder: LanguageService.get('error_code'),
                              keyboardType: TextInputType.text,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),

                            ),
                            const SizedBox(height: 16),

                            // Upload Media Section
                            GestureDetector(
                              onTap: () => model.pickMedia(),
                              child: DottedBorder(
                                color: AppColors.lightGray,
                                strokeWidth: 1.5,
                                dashPattern: [8, 4],
                                borderType: BorderType.RRect,
                                radius: Radius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(AppSizes.v16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_rounded, size: 24, color: AppColors.black),
                                      const SizedBox(width: 8),
                                      Text(
                                        LanguageService.get('upload_media'),
                                        style: TextStyle(color: AppColors.black, fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Show selected attachments
                            if (model.attachments.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(AppSizes.v12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${LanguageService.get('selected_files')} (${model.attachments.length})',
                                      style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    ...model.attachments.asMap().entries.map<Widget>((entry) {
                                      final index = entry.key;
                                      final file = entry.value;
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 4),
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4)),
                                        child: Row(
                                          children: [
                                            Icon(Icons.attach_file, size: 16, color: AppColors.primary),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                file.path.split('/').last,
                                                style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => model.removeAttachment(index),
                                              child: Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),

                            // Additional Notes
                            CommonTextField(
                              controller: model.additionalNotesController,
                              label: LanguageService.get('additional_notes'),
                              placeholder: LanguageService.get('additional_notes'),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 24),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(DialogResponse(confirmed: false));
                                      model.onCancel();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.lightGray),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: EdgeInsets.symmetric(vertical: AppSizes.h12),
                                    ),
                                    child: Text(
                                      LanguageService.get('cancel'),
                                      style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        model.isLoading
                                            ? null
                                            : () {
                                              if (model.formKey.currentState?.validate() ?? false) {
                                                Navigator.of(context).pop(DialogResponse(confirmed: true));
                                                model.onSubmit();
                                              }
                                            },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: EdgeInsets.symmetric(vertical: AppSizes.h12),
                                    ),
                                    child:
                                        model.isLoading
                                            ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                              ),
                                            )
                                            : Text(LanguageService.get('submit_ticket'), style: TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
