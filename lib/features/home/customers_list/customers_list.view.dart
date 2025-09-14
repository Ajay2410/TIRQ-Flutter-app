import 'package:flutter/material.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/country_flag/country_helper.dart';
import 'package:stacked/stacked.dart';
import '../../../core/models/hive/user/user.dart';
import '../../../resources/app_resources/app_resources.dart';
import 'customers_list.vm.dart';
import 'widgets/customer_card/customer_card.dart';

class CustomersListView extends StatefulWidget {
  const CustomersListView({super.key});

  @override
  State<CustomersListView> createState() => _CustomersListViewState();
}

class _CustomersListViewState extends State<CustomersListView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });

    if (_isSearchVisible) {
      _animationController.forward();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    } else {
      _animationController.reverse();
      _searchController.clear();
      _searchFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CustomersListViewModel>.reactive(
      viewModelBuilder: () => CustomersListViewModel(),
      onViewModelReady: (CustomersListViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (
          BuildContext context,
          CustomersListViewModel model,
          Widget? child,
          ) {
        return Scaffold(
          appBar: _buildAppBar(context, model),
          floatingActionButton: _buildFloatingActionButton(model),
          body: Column(
            children: [
              SlideTransition(
                position: _slideAnimation,
                child: _isSearchVisible
                    ? _buildSearchBar(context, model)
                    : const SizedBox.shrink(),
              ),
              Expanded(child: _buildCustomersList(context, model)),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context,
      CustomersListViewModel model,
      ) {
    return
      AppBar(
      elevation: 0,
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
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        getUser().organizationType == OrganizationType.manufacturer
            ? LanguageService.get("my_customers")
            :  LanguageService.get("my_machine_suppliers"),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16
        ),
      ),
      actions: [
        IconButton(
          onPressed: _toggleSearch,
          icon: Icon(
            _isSearchVisible ? Icons.close : Icons.search,
            color: AppColors.white,
          ),
        ),
        IconButton(
          onPressed: () {
            // Add filter functionality
            // Add filter functionality
          },
          icon: Icon(
            Icons.filter_list,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(CustomersListViewModel model) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: SizedBox(
        width: 103,
        height: 46,
        child: FloatingActionButton.extended(
          onPressed: () => model.showScanQrOptions(),
          backgroundColor: AppColors.primary,
          elevation: 4,
          icon: Icon(Icons.add, color: AppColors.white, size: 20),
          label: Text(
            LanguageService.get("add_new"),
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, CustomersListViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w16,
        vertical: AppSizes.h12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          model.searchQuery = value;
        },
        decoration: InputDecoration(
          hintText: 'Search by name or ID...',
          hintStyle: TextStyle(color: AppColors.gray),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          fillColor: AppColors.lightGray.withValues(alpha: 0.3),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.v12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: AppSizes.h12,
            horizontal: AppSizes.w16,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: AppColors.gray),
            onPressed: () {
              _searchController.clear();
              model.searchQuery = '';
            },
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildCustomersList(
      BuildContext context,
      CustomersListViewModel model,
      ) {
    if (model.isBusy) {
      return _buildLoadingState();
    }

    if (model.filteredRelationships.isEmpty) {
      return _buildEmptyState(context, model);
    }

    return RefreshIndicator(
      onRefresh: () async => model.refreshCustomers(),
      color: AppColors.primary,
      backgroundColor: AppColors.white,
      child: Container(
        color: AppColors.scaffoldBackground,
        child: ListView.builder(
          itemCount: model.filteredRelationships.length,
          itemBuilder: (context, index) {
            final relationship = model.filteredRelationships[index];
            final countryFlag = CountryHelper()
                .getCountryFlagFromDialCode(relationship.partnerCountryCode);

            return CustomerCard(
              attributes: CustomerCardAttributes(
                onTap: () => model.onCustomerTap(relationship),
                leadingImageUrl: relationship.partnerLogo ??
                    'https://img.freepik.com/free-vector/search-engine-logo_1071-76.jpg',
                title: relationship.partnerName ?? 'Unknown Customer',
                status: relationship.status?.name ?? 'Pending',
                countryFlag: countryFlag,
                relationship: relationship,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: AppColors.scaffoldBackground,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.w16,
          vertical: AppSizes.h8,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          return CustomerCardShimmer();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, CustomersListViewModel model) {
    return Container(
      color: AppColors.scaffoldBackground,
      child: Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.v32),
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people_alt_outlined,
                  size: 80,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: AppSizes.h24),
              Text(
                'No customers found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSizes.h8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.w40),
                child: Text(
                  model.searchQuery.isNotEmpty || model.selectedStatus != 'All'
                      ? 'Try changing your search or filters'
                      : 'Add customers to your network',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: AppSizes.h32),
              ElevatedButton.icon(
                onPressed: () => model.showScanQrOptions(),
                icon: Icon(Icons.add, color: AppColors.white),
                label: Text(
                  'Add New Customer',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.w24,
                    vertical: AppSizes.h12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.v12),
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