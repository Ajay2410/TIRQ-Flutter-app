import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/core/models/customer.dart';
import 'package:manager/features/home/my_customers/machine_details/customer_details/customer_edit_details.view.dart';
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

  void _onSearchChanged() {}

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SearchOrganizationViewModel>.reactive(
      viewModelBuilder: () => SearchOrganizationViewModel(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: _buildAppBar(context),

          body: Column(
            children: [
              Container(
                color: AppColors.scaffoldBackground,
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: _buildSearchTextField(context, model),
              ),

              Expanded(
                child: Container(
                  color: AppColors.scaffoldBackground,
                  child: _buildSearchContent(model),
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
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryLight, AppColors.primaryDark],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            stops: [0.08, 1],
          ),
        ),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              AppImages.search,
              width: 20,
              height: 20,
              color: AppColors.black,
            ),
          ),
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
                hintText: 'Search customers by name, phone, or email...',
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
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                model.clearSearch();
                model.cancelSearch();
              },
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Icon(Icons.close, color: AppColors.black, size: 20),
              ),
            ),
          if (model.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
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

  Widget _buildSearchContent(SearchOrganizationViewModel model) {
    if (model.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    }

    if (model.errorMessage != null) {
      return Center(
        child: Text(
          model.errorMessage!,
          style: const TextStyle(color: AppColors.error),
        ),
      );
    }

    if (model.searchResults.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: model.searchResults.length + 1,
      separatorBuilder:
          (context, index) =>
              index == 0
                  ? SizedBox()
                  : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Divider(color: AppColors.lightGrey, height: 1),
                  ),
      itemBuilder: (context, index) {
        if (index == 0) {
          return SizedBox(height: 10);
        }
        final result = model.searchResults[index - 1];
        return Container(
          color: AppColors.white,
          padding: EdgeInsets.all(10),
          child: _buildSearchResultItem(result, model),
        );
      },
    );
  }

  Widget _buildSearchResultItem(
    Customer result,
    SearchOrganizationViewModel model,
  ) {
    return InkWell(
      onTap: () async {
        final editResult = await Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => CustomerEditDetailsView(
                  customer: result,
                  isFromSearchOrganization: true,
                ),
          ),
        );

        if (editResult != null && editResult is Customer) {
          // Navigate back to my_customers and refresh
          Navigator.of(context).pop(true);
        }
      },
      child: Row(
        children: [
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
                    child: Container(
                      color: AppColors.bluebackground,
                      child: Center(
                        child: Text(
                          result.customerName?.substring(0, 2).toUpperCase() ??
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
                if (result.flag != null)
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Image.asset(AppImages.flag, width: 17, height: 17),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          Text(
            result.customerName ?? '',
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
