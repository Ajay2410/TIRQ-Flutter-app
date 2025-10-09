import 'package:flutter/material.dart';
import 'package:manager/core/models/customer.dart';
import 'package:manager/core/utils/screen_utils.dart';
import 'package:manager/features/home/my_customers/my_customers.vm.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:stacked/stacked.dart';
import 'package:shimmer/shimmer.dart';


class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> with TickerProviderStateMixin {
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
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _menuAnimationController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    _menuScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _menuAnimationController, curve: Curves.easeOutBack));
    _menuOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _menuAnimationController, curve: Curves.easeInOut));

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
      builder: (BuildContext context, MyCustomersViewModel model, Widget? child) {
        return Scaffold(
          appBar: _buildAppBar(context, model),
          body: Stack(
            children: [
              Column(
                children: [
                  SlideTransition(position: _slideAnimation, child: _isSearchVisible ? _buildSearchBar(context, model) : const SizedBox.shrink()),
                  Expanded(child: Container(color: AppColors.white, child: _buildCustomersList(context, model))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, MyCustomersViewModel model) {
    return GradientAppBar(
      titleSpacing: 0,
      leading: IconButton(
        icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleKey: 'Notification',
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
          prefixIcon: Padding(padding: const EdgeInsets.all(16), child: Image.asset(AppImages.search, width: 20, height: 20, color: AppColors.gray)),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.lightGrey)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary)),
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
          return Divider(color: AppColors.lightGrey, thickness: 1);
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
        return Divider(color: AppColors.lightGrey, thickness: 1);
      },
      padding: const EdgeInsets.all(13),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(baseColor: AppColors.lightGrey, highlightColor: AppColors.white, child: _buildCustomerCardShimmer());
      },
    );
  }

  Widget _buildCustomerCardShimmer() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.lightGrey),
          child: Container(height: 50, width: 50, decoration: BoxDecoration(color: AppColors.lightGrey, shape: BoxShape.circle)),
        ),
        AppGaps.w16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 16, width: 120, decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4))),
              AppGaps.h5,
              Container(height: 14, width: 200, decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4))),
            ],
          ),
        ),
        AppGaps.w16,
        Container(height: 20, width: 60, decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(6))),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, MyCustomersViewModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppImages.alert, width: 80, height: 80, color: AppColors.redBack),
          AppGaps.h20,
          Text(
            LanguageService.get('error_loading_customers'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          AppGaps.h10,
          Text(model.errorMessage, style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
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
          Image.asset(AppImages.myCustomers, width: 80, height: 80, color: AppColors.gray),
          AppGaps.h20,
          Text(LanguageService.get('no_customers_found'), style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer, MyCustomersViewModel model, BuildContext context) {
    return InkWell(
      onTap: () => model.onCustomerTap(context, customer),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.colorF0F2FC),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(color: AppColors.bluebackground, shape: BoxShape.circle),
              child: ClipOval(
                child: Container(
                  color: AppColors.bluebackground,
                  child: Center(
                    child: Text(
                      customer.customerName?.substring(0, 2).toUpperCase() ?? 'NA',
                      style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),

          AppGaps.w16,

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        customer.customerName ?? 'Unknown Customer',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
                AppGaps.h5,
                Text(
                  // _buildCustomerDescription(customer),
                  "Connection Request",
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          AppGaps.w16,

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Accept',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success),
                ),
              ),
              SizedBox(width: 10.h),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.redBack.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                 'Reject',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.redBack),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



}
