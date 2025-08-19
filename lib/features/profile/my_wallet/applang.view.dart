import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manager/features/profile/my_wallet/controller/languageController';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';

class AppLanguageView extends StatelessWidget {
  AppLanguageView({super.key});

  final controller = Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body:
      Container(
        color: AppColors.white,
        child: Column(
          children: [
            _buildSearchBar(context),
            Container(height: AppSizes.h16, color: AppColors.lightGray),
            _buildLanguageList(context),
          ],
        ),
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
        LanguageService.get("App Language"),
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: IconThemeData(color: AppColors.white),
    );
    //   },
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search Language',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: controller.updateSearch,
      ),
    );
  }

  Widget _buildLanguageList(BuildContext context) {
    // This method would return a list of languages available in the app
    // For now, we can just return a placeholder widget
    return Expanded(
      child: Obx(
        () => ListView.separated(
          separatorBuilder:
              (context, index) => Divider(
                height: 1,
                thickness: 1,
                color: AppColors.gray.withValues(alpha: 0.2),
                endIndent: 16,
              ),
          itemCount: controller.filteredLanguages.length,
          itemBuilder: (_, index) {
            final lang = controller.filteredLanguages[index];
            return ListTile(
              leading: Text(lang.flag, style: TextStyle(fontSize: 24)),
              title: Text(
                LanguageService.get(lang.name),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Obx(
                () => Radio<String>(
                  value: lang.code,
                  groupValue: controller.selectedLanguageCode.value,
                  onChanged: (val) => controller.selectLanguage(val!),
                ),
              ),
              onTap: () => controller.selectLanguage(lang.code),
            );
          },
        ),
      ),
    );
  }
}
