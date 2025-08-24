import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common_text_field.dart';
import '../add_new_machine_model.view.dart';

class MachineDetailsView extends StatefulWidget {
  final Map<String, dynamic> machine;

  const MachineDetailsView({super.key, required this.machine});

  @override
  State<MachineDetailsView> createState() => _MachineDetailsViewState();
}

class _MachineDetailsViewState extends State<MachineDetailsView> {
  late TextEditingController _remarkController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _remarkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Container(
                color: AppColors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildMachineDetails(),
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: Image.asset(
          AppImages.back,
          width: 24,
          height: 24,
          color: AppColors.white,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Text(
        '${"machine_id".lang} - ${"machine_name".lang}',
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMachineDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Machine / Model Name
        CommonTextField(
          controller: TextEditingController(
            text: '${"machine_id".lang} - ${"machine_name".lang}',
          ),
          label: 'machine_model_name'.lang,
          placeholder: '',
          readOnly: true,
          enabled: false,
          disabledBackgroundColor: const Color(0xFFF8FBFE),
        ),
        const SizedBox(height: 16),

        // Model Number
        CommonTextField(
          controller: TextEditingController(text: 'machine_id'.lang),
          label: 'model_number'.lang,
          placeholder: '',
          readOnly: true,
          enabled: false,
          disabledBackgroundColor: const Color(0xFFF8FBFE),
        ),
        const SizedBox(height: 16),

        // Functionality
        CommonTextField(
          controller: TextEditingController(text: 'fully_automatic'.lang),
          label: 'functionality'.lang,
          placeholder: '',
          readOnly: true,
          enabled: false,
          disabledBackgroundColor: const Color(0xFFF8FBFE),
        ),
        const SizedBox(height: 16),

        // Remark
        CommonTextField(
          controller: _remarkController,
          label: 'remark'.lang,
          placeholder: 'enter_remark_here'.lang,
          maxLines: 1,
          suffixIcon: CustomPopup(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add machine add-ons like:',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '''• Machine with 2/4 station loader\n• Machine with loader & unloader\n• Machine with Auto detection\n• Machine with Single/double blower (furnace/washing)\netc.''',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            position: PopupPosition.top,
            arrowColor: AppColors.textGray,
            backgroundColor: AppColors.textGray,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Image.asset(AppImages.alert, width: 16, height: 16),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Processing Dimensions
        _buildSectionTitle('processing_dimensions'.lang),
        const SizedBox(height: 16),

        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'maximum_processing_size'.lang,
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              AppImages.height,
                              'height'.lang,
                              '1.0',
                              AppColors.color41C293,
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: _buildInfoRow(
                              AppImages.width,
                              'width'.lang,
                              '1.0',
                              AppColors.primarySuperLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(height: 56, color: AppColors.lightGray, width: 1),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'minimum_processing_size'.lang,
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              AppImages.height,
                              'height'.lang,
                              '1.0',
                              AppColors.color41C293,
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: _buildInfoRow(
                              AppImages.width,
                              'width'.lang,
                              '1.0',
                              AppColors.primarySuperLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),
        Divider(color: AppColors.lightGray),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                AppImages.height,
                'thickness'.lang,
                '1.0',
                AppColors.color41C293,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: _buildInfoRow(
                AppImages.width,
                'max_speed'.lang,
                '1.0',
                AppColors.primarySuperLight,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        Divider(color: AppColors.lightGray),
        const SizedBox(height: 20),

        _buildInfoRow(
          AppImages.width,
          "${'total_power'.lang} (kw)",
          '1.0',
          AppColors.primarySuperLight,
        ),
        const SizedBox(height: 24),

        // Notes/Special Instructions
        CommonTextField(
          controller: _notesController,
          label: 'notes_special_instructions'.lang,
          placeholder: 'link_here'.lang,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 36),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Navigate to edit screen with current machine data
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            AddNewMachineModelView(machine: widget.machine),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                elevation: 5,

                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45),
                ),
              ),
              child: Text(
                'edit'.lang,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 26),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _showDeleteConfirmation(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redBack,
                elevation: 5,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45),
                ),
              ),
              child: Text(
                'remove'.lang,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String iconPath,
    String label,
    String value,
    Color iconColor, {
    bool isWarning = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.asset(iconPath, width: 17, height: 17, color: iconColor),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: isWarning ? AppColors.redBack : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(10),
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.redBack.withValues(alpha: 0.1),
                  ),
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.redBack,
                    ),
                    child: const Center(
                      child: Text(
                        '!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Main Question Text
                Text(
                  'are_you_sure_remove_machine'.lang,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.darkGray,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          side: BorderSide(
                            color: AppColors.darkGray,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(45),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'cancel'.lang,
                          style: TextStyle(
                            color: AppColors.darkGray,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Remove Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Handle delete action here
                          // You can add your delete logic here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.redBack,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(45),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'remove'.lang,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Warning Message
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'remove_machine_warning'.lang,
                    style: TextStyle(
                      color: AppColors.redBack,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
