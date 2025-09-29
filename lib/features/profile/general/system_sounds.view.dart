import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common_app_bar.dart';

class SystemSoundsView extends StatelessWidget {
  const SystemSoundsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cultured,
      appBar: _buildAppBar(context),
      body: _buildContent(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return GradientAppBar(titleKey: "system_sound", titleSpacing: 0);
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: AppSizes.v10, bottom: AppSizes.v10),
      child: Column(
        children: [
          _buildSoundCategory(
            title: LanguageService.get("ticket_notification"),
            currentSound: "Bamboo",
            onTap:
                () => _showSoundSelectionDialog(
                  context,
                  LanguageService.get("ticket_notification"),
                ),
          ),
          _buildSoundCategory(
            title: LanguageService.get("voice_call"),
            currentSound: "Bamboo",
            onTap:
                () => _showSoundSelectionDialog(
                  context,
                  LanguageService.get("voice_call"),
                ),
          ),
          _buildSoundCategory(
            title: LanguageService.get("video_call"),
            currentSound: "Bamboo",
            onTap:
                () => _showSoundSelectionDialog(
                  context,
                  LanguageService.get("video_call"),
                ),
          ),
          _buildSoundCategory(
            title: LanguageService.get("alert_sound"),
            currentSound: "Bamboo",
            onTap:
                () => _showSoundSelectionDialog(
                  context,
                  LanguageService.get("alert_sound"),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundCategory({
    required String title,
    required String currentSound,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(vertical: 15,horizontal: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(13),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.primarySuperLight.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.textGray.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      LanguageService.get("sound"),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    currentSound,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.textGray,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.gunmetal,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSoundSelectionDialog(BuildContext context, String category) {
    final sounds = [
      "Bamboo",
      "Bell",
      "Chime",
      "Ding",
      "Notification",
      "Pop",
      "Ring",
      "Tone",
      "Whistle",
    ];

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset(AppImages.systemSound, width: 24, height: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              // Sound List
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(16),
                  itemCount: sounds.length,
                  separatorBuilder:
                      (context, index) => Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.gray.withValues(alpha: 0.2),
                      ),
                  itemBuilder: (context, index) {
                    final sound = sounds[index];
                    return ListTile(
                      leading: Icon(
                        Icons.music_note,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      title: Text(
                        sound,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing:
                          sound == "Bamboo"
                              ? Icon(
                                Icons.check,
                                color: AppColors.primary,
                                size: 20,
                              )
                              : null,
                      onTap: () {
                        _onSoundSelected(sound, category);
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSoundSelected(String sound, String category) {
    // Handle sound selection
    Get.snackbar(
      LanguageService.get("sound_selected"),
      '${LanguageService.get("selected_sound")}: $sound',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryLight,
      colorText: AppColors.white,
    );
  }
}
