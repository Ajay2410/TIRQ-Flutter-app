import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manager/features/profile/my_wallet/applang.view.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';

class GeneralSettingView extends StatelessWidget {
  const GeneralSettingView({super.key});

  void showTranslationDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(onPressed: () {}, icon: Icon(Icons.close)),
              ),
              CircleAvatar(
                backgroundColor: Color(0xFF687FE5).withValues(alpha: 0.1),
                radius: 40,
                child: Image.asset('assets/images/translate.png'),
              ),
               SizedBox(height: 10),
               Text(
                LanguageService.get("chat_translation"),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(),
                child: ListTile(
                  tileColor: AppColors.lightGray.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  // backgroundColor: AppColors.lightGray.withValues(alpha: 0.1) ,
                  title: Text(
                    LanguageService.get('translate_text_to'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: TextButton.icon(
                    icon: Icon(Icons.arrow_forward_ios),
                    style: TextButton.styleFrom(
                      iconAlignment: IconAlignment.end,
                      iconColor: AppColors.darkGray.withValues(alpha: 0.7),
                      side: BorderSide.none,
                    ),
                    onPressed: () {
                      // You can use Get.bottomSheet or another dialog here for language selection
                    },
                    label: Text(
                      LanguageService.get('english'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGray.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Text(
                LanguageService.get(
                  'after_it_is_enabled_text_in_chats_will_be_translated_into_the_selected_language.',
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 10),
              // Obx(() =>
              SwitchListTile(
                tileColor: AppColors.lightGray.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                value: true,
                // ChatSettingsController.to.autoTranslate.value,
                onChanged: (val) {
                  //   ChatSettingsController.to.autoTranslate.value = val;
                },
                title: Text(
                  LanguageService.get(
                    'auto_translate_messages_received_in_chat',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                //  const Text("Auto Translate Messages received in chat"),
                // subtitle: const Text("After it is enabled, text in chats will be translated into the selected language."),
              ),
              // ),
              const SizedBox(height: 10),

              Text(
                LanguageService.get(
                  'after_it_is_enabled_text_in_chats_will_be_translated_into_the_selected_language',
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body:
      Container(
          color: AppColors.white,
          child: _buildContent(context)
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(Icons.arrow_back, color: AppColors.white),
      ),

      title: Text(
        LanguageService.get("general"),
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: IconThemeData(color: AppColors.white),
    );
    //   },
  }

  Widget _buildContent(BuildContext context) {
    // Define settings items data
    final List<Map<String, dynamic>> settingsItems = [
      {
        'title': LanguageService.get("app_language"),
        'icon': 'assets/images/language-square.png',
        'backgroundColor': AppColors.bluebackground.withValues(alpha: 0.2),
        'onTap': () {
          Get.to(() => AppLanguageView()); // Navigate to app language settings
          // Navigate to app language settings
        },
        'hasTrailing': true,
        'hasToggle': false, // New property to identify toggle
      },
      {
        'title': LanguageService.get("chat_language"),
        'icon': 'assets/images/messages.png',
        'backgroundColor': AppColors.greenbackground.withValues(alpha: 0.2),
        'onTap': () {
          showTranslationDialog(context); // Show translation dialog
          // Navigate to chat language settings
        },
        'hasTrailing': true,
        'hasToggle': false, // New property to identify toggle
      },
      {
        'title':  LanguageService.get("system_sound"),
        'icon': 'assets/images/music.png',
        'backgroundColor': AppColors.redbackground.withValues(alpha: 0.2),
        'onTap': () {
          // Navigate to system sound settings
        },
        'hasTrailing': true,
        'hasToggle': false, // New property to identify toggle
      },
      {
        'title':  LanguageService.get("appearance"),
        'icon': 'assets/images/colorfilter.png',
        'backgroundColor': AppColors.bluebackground.withValues(alpha: 0.2),
        'onTap': () {
          // Navigate to appearance settings
        },
        'hasTrailing': false,
        'hasToggle': true, // New property to identify toggle
      },
    ];

    return
      Container(
        color: AppColors.white,
        height: MediaQuery.of(context).size.height,
        child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.only(top: AppSizes.v10, bottom: AppSizes.v10),
        itemCount: settingsItems.length,
        separatorBuilder:
            (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: AppColors.gray.withValues(alpha: 0.2),
              endIndent: 16,
            ),
        itemBuilder: (context, index) {
          final item = settingsItems[index];

          return ListTile(
            leading: _buildLeadingIcon(item['backgroundColor'], item['icon']),
            title: Text(
              LanguageService.get(item['title']),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            onTap: item['onTap'],
            trailing:
                item['hasToggle']
                    ? _buildThemeToggle(context) // Only for Appearance
                    : (item['hasTrailing']
                        ? _buildTrailingIcon()
                        : SizedBox(width: 0, height: 0)),
          );
        },
            ),
      );
  }

  Widget _buildThemeToggle(BuildContext context) {
    bool isDarkMode = true; // Default to Dark (you can manage this with state)

    return SizedBox(
      width: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            LanguageService.get('light'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w100,
              color: AppColors.textPrimary,
            ),
          ),
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              // Update theme here (use Provider/Bloc/GetX if needed)
              // Example: ThemeController().toggleTheme(value);
            },

            activeColor: AppColors.lightGray.withValues(alpha: 0.9),
            inactiveThumbColor: AppColors.lightGray.withValues(alpha: 0.9),
            inactiveTrackColor: AppColors.lightGray.withValues(alpha: 0.9),
          ),
          Text(
            LanguageService.get('dark'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w100,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for trailing icon to reduce code duplication
  Widget _buildTrailingIcon() {
    return Container(
      padding: EdgeInsets.all(AppSizes.w8),
      decoration: BoxDecoration(
        color: AppColors.gray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.v10),
        border: Border.all(
          color: AppColors.gray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.arrow_forward_rounded,
        size: 18,
        color: AppColors.darkGray,
      ),
    );
  }

  Widget _buildLeadingIcon(Color backgroundColor, String iconPath) {
    // Your existing implementation here
    return Container(
      padding: EdgeInsets.all(AppSizes.w8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.v10),
      ),
      child: Image.asset(iconPath, width: 24, height: 24),
    );
  }
}
