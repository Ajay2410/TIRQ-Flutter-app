import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:manager/features/profile/my_wallet/controller/languageController';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:manager/widgets/common_elevated_button.dart';

class AppLanguageView extends StatefulWidget {
  const AppLanguageView({super.key});

  @override
  State<AppLanguageView> createState() => _AppLanguageViewState();
}

class _AppLanguageViewState extends State<AppLanguageView> with SingleTickerProviderStateMixin {
  final controller = Get.put(LanguageController());
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(context),
      bottomNavigationBar: _buildSaveButton(context),
      body: Column(children: [_buildSearchBar(context), Expanded(child: _buildLanguageList(context))]),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return GradientAppBar(titleKey: "app_language");
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.05), offset: const Offset(0, 2), blurRadius: 8)],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          controller.updateSearch(value);
        },
        decoration: InputDecoration(
          hintText: 'Search Language',
          hintStyle: TextStyle(color: AppColors.gray),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          fillColor: AppColors.lightGray.withOpacity(0.3),
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.gray),
                    onPressed: () {
                      _searchController.clear();
                      controller.updateSearch('');
                    },
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _buildLanguageList(BuildContext context) {
    return Obx(
      () => ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: controller.filteredLanguages.length,
        itemBuilder: (_, index) {
          final lang = controller.filteredLanguages[index];
          final isSelected = controller.selectedLanguageCode.value == lang.code;

          return Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => controller.selectLanguage(lang.code),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      // Flag container
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.softGray.withOpacity(0.1)),
                        child: Center(child: Text(lang.flag, style: TextStyle(fontSize: 28))),
                      ),
                      SizedBox(width: 16),
                      // Language info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lang.name, style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text(
                              _getCountryName(lang.code),
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                      // Radio button
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.lightGray, width: 2),
                          color: isSelected ? AppColors.primary : AppColors.white,
                        ),
                        child:
                            isSelected
                                ? Center(
                                  child: Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.white)),
                                )
                                : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getCountryName(String code) {
    switch (code) {
      case 'us':
        return 'United States';
      case 'uk':
        return 'United Kingdom';
      case 'eg':
        return 'Egypt (Syria)';
      case 'th':
        return 'Thailand (ประเทศไทย)';
      case 'dk':
        return 'Denmark (Storbritannien)';
      case 'de':
        return 'Germany (Deutschland)';
      default:
        return '';
    }
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 13),
      margin: EdgeInsets.only(bottom: 10),
      child: CommonElevatedButton(
        label: LanguageService.get('save_changes'),
        onPressed: () {
          Navigator.of(context).pop();
        },
        backgroundColor: AppColors.primaryDark,
        textColor: AppColors.white,
        borderRadius: 45,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
