import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';
import 'search_organization.vm.dart';

class SearchOrganizationView extends StatefulWidget {
  const SearchOrganizationView({super.key});

  @override
  State<SearchOrganizationView> createState() => _SearchOrganizationViewState();
}

class _SearchOrganizationViewState extends State<SearchOrganizationView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // This will be handled by the ViewModel
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SearchOrganizationViewModel>.reactive(
      viewModelBuilder: () => SearchOrganizationViewModel(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: _buildAppBar(context),

          body: Column(
            children: [
              // Search Bar
              Container(
                color: AppColors.scaffoldBackground,
                padding: const EdgeInsets.all(16),
                child: _buildSearchTextField(context, model),
              ),

              // Content Area
              Expanded(
                child: Container(
                  color: AppColors.scaffoldBackground,
                  child:
                      model.searchResults.isEmpty
                          ? _buildEmptyState()
                          : _buildSearchResults(model),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
      title: Text(
        LanguageService.get('search_by_phone_number_email'),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      titleSpacing: 0,
    );
  }

  Widget _buildSearchTextField(
    BuildContext context,
    SearchOrganizationViewModel model,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search icon
          Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              AppImages.search,
              width: 20,
              height: 20,
              color: AppColors.black,
            ),
          ),
          // Text field
          Expanded(
            child: TextFormField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: model.performSearch,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.black,
                fontWeight: FontWeight.w500,
              ),
              onTapOutside: (event) {
                _searchFocusNode.unfocus();
              },
              decoration: const InputDecoration(
                hintText: 'Search organizations...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 16,
                ),
              ),
            ),
          ),
          // Clear button
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                model.clearSearch();
              },
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Icon(Icons.close, color: AppColors.black, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Image.asset(
        AppImages.earthSearch,
        width: 280,
        height: 280,
        color: AppColors.gray,
      ),
    );
  }

  Widget _buildSearchResults(SearchOrganizationViewModel model) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: model.searchResults.length,
      separatorBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Divider(color: AppColors.lightGray, height: 1),
          ),
      itemBuilder: (context, index) {
        final result = model.searchResults[index];
        return _buildSearchResultItem(result);
      },
    );
  }

  Widget _buildSearchResultItem(Map<String, String> result) {
    return GestureDetector(
      onTap: () {
        // Handle tap on search result item
        // You can add navigation or other actions here
      },
      child: Row(
        children: [
          // Left side - Company icon and flag
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.colorF0F2FC,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: AppColors.bluebackground,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child:
                        result['avatar'] != null &&
                                result['avatar']!.startsWith('http')
                            ? Image.network(
                              result['avatar']!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.bluebackground,
                                  child: Center(
                                    child: Text(
                                      result['name']
                                              ?.substring(0, 2)
                                              .toUpperCase() ??
                                          '',
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: AppColors.bluebackground,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                            : Container(
                              color: AppColors.bluebackground,
                              child: Center(
                                child: Text(
                                  result['name']
                                          ?.substring(0, 2)
                                          .toUpperCase() ??
                                      '',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                  ),
                ),
                // Flag icon at bottom
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Image.asset(AppImages.flag, width: 17, height: 17),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Middle section - Customer name and description
          Text(
            result['name'] ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
