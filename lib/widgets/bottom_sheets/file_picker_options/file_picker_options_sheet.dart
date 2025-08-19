import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked_services/stacked_services.dart';

class FilePickerOptionsSheetAttributes {
  final String? title;
  final String? message;

  FilePickerOptionsSheetAttributes({this.title, this.message});
}

class FilePickerOptionsSheet extends StatelessWidget {
  final SheetRequest<FilePickerOptionsSheetAttributes> request;
  final Function(SheetResponse) completer;

  const FilePickerOptionsSheet({
    super.key,
    required this.request,
    required this.completer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w20,
        vertical: AppSizes.h20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.v20),
          topRight: Radius.circular(AppSizes.v20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          if (request.data?.title != null)
            Padding(
              padding: EdgeInsets.only(bottom: AppSizes.h16),
              child: Text(
                request.data!.title!,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),

          // Description
          if (request.data?.message != null)
            Padding(
              padding: EdgeInsets.only(bottom: AppSizes.h20),
              child: Text(
                request.data!.message!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),

          // Option buttons
          _buildOption(
            context,
            title: LanguageService.get("take_photo"),
            icon: Icons.camera_alt,
            color: AppColors.primary,
            onTap: () {
              completer(SheetResponse(confirmed: true, data: 'camera'));
            },
          ),

          SizedBox(height: AppSizes.h12),

          _buildOption(
            context,
            title: LanguageService.get("choose_from_gallery"),
            icon: Icons.photo_library,
            color: AppColors.success,
            onTap: () {
              completer(SheetResponse(confirmed: true, data: 'gallery'));
            },
          ),

          // SizedBox(height: AppSizes.h12),
          //
          // _buildOption(
          //   context,
          //   title: 'Attach Document',
          //   icon: Icons.insert_drive_file,
          //   color: AppColors.warning,
          //   onTap: () {
          //     completer(SheetResponse(confirmed: true, data: 'document'));
          //   },
          // ),

          SizedBox(height: AppSizes.h16),

          // Cancel button
          TextButton(
            onPressed: () {
              completer(SheetResponse(confirmed: false));
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: EdgeInsets.symmetric(vertical: AppSizes.h16),
            ),
            child: Text(
              request.mainButtonTitle ?? LanguageService.get("cancel"),
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          // Add extra padding at the bottom to account for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.v12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.w16,
          vertical: AppSizes.h16,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(AppSizes.v12),
          border: Border.all(color: color.withValues(alpha:0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.v10),
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: AppSizes.v24),
            ),
            SizedBox(width: AppSizes.w16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
