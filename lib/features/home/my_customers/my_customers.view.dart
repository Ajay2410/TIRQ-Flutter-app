import 'package:flutter/material.dart';
import 'package:manager/core/models/customer.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';
import 'package:shimmer/shimmer.dart';
import 'my_customers.vm.dart';

class MyCustomersView extends StatefulWidget {
  const MyCustomersView({super.key});

  @override
  State<MyCustomersView> createState() => _MyCustomersViewState();
}

class _MyCustomersViewState extends State<MyCustomersView>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late AnimationController _menuAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _menuScaleAnimation;
  late Animation<double> _menuOpacityAnimation;
  bool _isSearchVisible = false;
  bool _isAddMenuVisible = false;

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
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _menuAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _menuScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _menuAnimationController,
        curve: Curves.easeOutBack,
      ),
    );
    _menuOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _menuAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    _menuAnimationController.dispose();
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

  void _toggleAddMenu() {
    setState(() {
      _isAddMenuVisible = !_isAddMenuVisible;
    });

    if (_isAddMenuVisible) {
      _menuAnimationController.forward();
    } else {
      _menuAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MyCustomersViewModel>.reactive(
      viewModelBuilder: () => MyCustomersViewModel(),
      onViewModelReady: (MyCustomersViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (
        BuildContext context,
        MyCustomersViewModel model,
        Widget? child,
      ) {
        return Scaffold(
          appBar: _buildAppBar(context, model),
          floatingActionButton: _buildFloatingActionButton(model),
          body: Stack(
            children: [
              Column(
                children: [
                  SlideTransition(
                    position: _slideAnimation,
                    child:
                        _isSearchVisible
                            ? _buildSearchBar(context, model)
                            : const SizedBox.shrink(),
                  ),
                  Expanded(
                    child: Container(
                      color: AppColors.white,
                      child: _buildCustomersList(context, model),
                    ),
                  ),
                ],
              ),
              if (_isAddMenuVisible) _buildAddMenuOverlay(model),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    MyCustomersViewModel model,
  ) {
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
        LanguageService.get('my_customers'),
        style: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      titleSpacing: 0,
      actions: [
        IconButton(
          icon: Image.asset(
            AppImages.search,
            width: 24,
            height: 24,
            color: AppColors.white,
          ),
          onPressed: _toggleSearch,
        ),
        PopupMenuButton<String>(
          icon: Stack(
            children: [
              Image.asset(
                AppImages.filter,
                width: 24,
                height: 24,
                color: AppColors.white,
              ),
              if (model.statusFilter != 'all')
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          menuPadding: EdgeInsets.zero,
          offset: Offset(-10, 40),
          onSelected: (String value) {
            model.onStatusFilterChanged(value);
          },
          itemBuilder:
              (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'all',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      LanguageService.get('all_customers'),
                      style: TextStyle(
                        color:
                            model.statusFilter == 'all'
                                ? AppColors.primary
                                : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight:
                            model.statusFilter == 'all'
                                ? FontWeight.w600
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                PopupMenuDivider(height: 0),
                PopupMenuItem<String>(
                  value: 'active',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      LanguageService.get('active_customer'),
                      style: TextStyle(
                        color:
                            model.statusFilter == 'active'
                                ? AppColors.primary
                                : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight:
                            model.statusFilter == 'active'
                                ? FontWeight.w600
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                PopupMenuDivider(height: 0),
                PopupMenuItem<String>(
                  value: 'inactive',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      LanguageService.get('inactive_customer'),
                      style: TextStyle(
                        color:
                            model.statusFilter == 'inactive'
                                ? AppColors.primary
                                : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight:
                            model.statusFilter == 'inactive'
                                ? FontWeight.w600
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppColors.white,
          shadowColor: AppColors.black.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, MyCustomersViewModel model) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: LanguageService.get('search_customers'),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              AppImages.search,
              width: 20,
              height: 20,
              color: AppColors.gray,
            ),
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.gray),
                    onPressed: () {
                      _searchController.clear();
                      model.clearSearch();
                    },
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.lightGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
        onChanged: model.onSearchChanged,
      ),
    );
  }

  Widget _buildCustomersList(BuildContext context, MyCustomersViewModel model) {
    if (model.isLoading) {
      return _buildShimmerList();
    }

    if (model.hasError) {
      return _buildErrorState(context, model);
    }

    if (model.filteredCustomers.isEmpty) {
      return _buildEmptyState(context, model);
    }

    return RefreshIndicator(
      onRefresh: model.refreshCustomers,
      backgroundColor: AppColors.white,
      child: ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(color: AppColors.lightGray, thickness: 1);
        },
        padding: const EdgeInsets.all(13),
        itemCount: model.filteredCustomers.length,
        itemBuilder: (context, index) {
          final customer = model.filteredCustomers[index];
          return _buildCustomerCard(customer, model, context);
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return Divider(color: AppColors.lightGray, thickness: 1);
      },
      padding: const EdgeInsets.all(13),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.lightGray,
          highlightColor: AppColors.white,
          child: _buildCustomerCardShimmer(),
        );
      },
    );
  }

  Widget _buildCustomerCardShimmer() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lightGray,
          ),
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              shape: BoxShape.circle,
            ),
          ),
        ),
        AppGaps.w16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 16,
                width: 120,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AppGaps.h5,
              Container(
                height: 14,
                width: 200,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        AppGaps.w16,
        Container(
          height: 20,
          width: 60,
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, MyCustomersViewModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppImages.alert,
            width: 80,
            height: 80,
            color: AppColors.redBack,
          ),
          AppGaps.h20,
          Text(
            LanguageService.get('error_loading_customers'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          AppGaps.h10,
          Text(
            model.errorMessage,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          AppGaps.h20,
          ElevatedButton(
            onPressed: model.refreshCustomers,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(LanguageService.get('retry')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, MyCustomersViewModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppImages.myCustomers,
            width: 80,
            height: 80,
            color: AppColors.gray,
          ),
          AppGaps.h20,
          Text(
            LanguageService.get('no_customers_found'),
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(
    Customer customer,
    MyCustomersViewModel model,
    BuildContext context,
  ) {
    return InkWell(
      onTap: () => model.onCustomerTap(context, customer),
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
                          customer.customerName
                                  ?.substring(0, 2)
                                  .toUpperCase() ??
                              'NA',
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
                if (customer.flag != null)
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: AppImages.getSvgFlag(
                        customer.flag!,
                        width: 14,
                        height: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          AppGaps.w16,

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.customerName ?? 'Unknown Customer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppGaps.h5,
                Text(
                  _buildCustomerDescription(customer),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          AppGaps.w16,

          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color:
                  (customer.isActive == true)
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.redBack.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              (customer.isActive == true) ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    (customer.isActive == true)
                        ? AppColors.success
                        : AppColors.redBack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildCustomerDescription(Customer customer) {
    if (customer.machines?.isEmpty != false) {
      return 'No machines assigned';
    }

    List<String> machineNames = [];
    for (var machineElement in customer.machines!) {
      if (machineElement.machine?.machineName != null) {
        machineNames.add(machineElement.machine!.machineName!);
      }
    }

    if (machineNames.isEmpty) return 'No machines assigned';
    return machineNames.join(', ');
  }

  Widget _buildFloatingActionButton(MyCustomersViewModel model) {
    return FloatingActionButton.extended(
      onPressed: _toggleAddMenu,
      backgroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      icon: Icon(
        _isAddMenuVisible ? Icons.close : Icons.add_rounded,
        size: 20,
        color: AppColors.white,
      ),
      extendedIconLabelSpacing: 0,
      label:
          _isAddMenuVisible
              ? const SizedBox.shrink()
              : Text(
                "  ${LanguageService.get('add_new')}",
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
    );
  }

  Widget _buildAddMenuOverlay(MyCustomersViewModel model) {
    return AnimatedBuilder(
      animation: _menuAnimationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            _toggleAddMenu();
          },
          child: Container(
            color: AppColors.black.withValues(
              alpha: 0.4 * _menuOpacityAnimation.value,
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: Transform.scale(
                    scale: _menuScaleAnimation.value,
                    child: Container(
                      width: 280,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 16,
                              left: 16,
                              bottom: 4,
                            ),
                            child: Text(
                              LanguageService.get('add_new_customer'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),

                          _buildMenuOption(
                            icon: AppImages.camera,
                            title: LanguageService.get(
                              'scan_from_camera_gallery',
                            ),
                            onTap: () {
                              _toggleAddMenu();
                              model.onScanFromCamera();
                            },
                            iconColor: AppColors.colorFFB141,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Divider(
                              height: 1,
                              color: AppColors.lightGray,
                            ),
                          ),
                          _buildMenuOption(
                            icon: AppImages.phone,
                            title: LanguageService.get(
                              'search_by_phone_number_email',
                            ),
                            onTap: () {
                              _toggleAddMenu();
                              model.onSearchByPhone(context);
                            },
                            iconColor: AppColors.color41C293,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Divider(
                              height: 1,
                              color: AppColors.lightGray,
                            ),
                          ),
                          _buildMenuOption(
                            icon: AppImages.addCircle,
                            title: LanguageService.get('create_new_customer'),
                            subtitle: LanguageService.get(
                              'create_a_new_customer',
                            ),
                            onTap: () {
                              _toggleAddMenu();
                              model.onAddNewCustomer(context);
                            },
                            iconColor: AppColors.color0ABAB5,
                          ),
                        ],
                      ),
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

  Widget _buildMenuOption({
    required String icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor?.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.asset(
                  icon,
                  width: 22,
                  height: 22,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
