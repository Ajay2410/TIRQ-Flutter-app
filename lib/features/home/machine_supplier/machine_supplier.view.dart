import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/core/models/machine_supplier_model.dart';
import 'package:stacked/stacked.dart';
import 'package:shimmer/shimmer.dart';
import 'machine_supplier.vm.dart';

class MachineSupplierView extends StatefulWidget {
  const MachineSupplierView({super.key});

  @override
  State<MachineSupplierView> createState() => _MachineSupplierViewState();
}

class _MachineSupplierViewState extends State<MachineSupplierView> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

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
    return ViewModelBuilder<MachineSupplierViewModel>.reactive(
      viewModelBuilder: () => MachineSupplierViewModel(),
      onViewModelReady: (MachineSupplierViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (BuildContext context, MachineSupplierViewModel model, Widget? child) {
        return Scaffold(
          appBar: _buildAppBar(context, model),
          body: Column(
            children: [
              SlideTransition(position: _slideAnimation, child: _isSearchVisible ? _buildSearchBar(context, model) : const SizedBox.shrink()),
              Expanded(child: Container(color: AppColors.scaffoldBackground, child: _buildMachinesList(context, model))),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, MachineSupplierViewModel model) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(LanguageService.get('machine_supplier'), style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      titleSpacing: 0,
      actions: [IconButton(icon: Image.asset(AppImages.search, width: 24, height: 24, color: AppColors.white), onPressed: _toggleSearch)],
    );
  }

  Widget _buildSearchBar(BuildContext context, MachineSupplierViewModel model) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: LanguageService.get('search_machines'),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.lightGray)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary)),
        ),
        onChanged: model.onSearchChanged,
      ),
    );
  }

  Widget _buildMachinesList(BuildContext context, MachineSupplierViewModel model) {
    if (model.isLoading) {
      return _buildShimmerList();
    }

    if (model.hasError) {
      return _buildErrorState(context, model);
    }

    if (model.filteredMachines.isEmpty) {
      return _buildEmptyState(context, model);
    }

    return RefreshIndicator(
      onRefresh: model.refreshMachines,
      backgroundColor: AppColors.white,
      child: ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(color: AppColors.lightGray, thickness: 1);
        },
        padding: const EdgeInsets.all(13),
        itemCount: model.filteredMachines.length,
        itemBuilder: (context, index) {
          final machine = model.filteredMachines[index];
          return _buildMachineCard(machine, model, context);
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
        return Shimmer.fromColors(baseColor: AppColors.lightGray, highlightColor: AppColors.white, child: _buildMachineCardShimmer());
      },
    );
  }

  Widget _buildMachineCardShimmer() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.lightGray),
          child: Container(height: 50, width: 50, decoration: BoxDecoration(color: AppColors.lightGray, shape: BoxShape.circle)),
        ),
        AppGaps.w16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 16, width: 120, decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(4))),
              AppGaps.h5,
              Container(height: 14, width: 200, decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(4))),
            ],
          ),
        ),
        AppGaps.w16,
        Container(height: 20, width: 60, decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(6))),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, MachineSupplierViewModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppImages.alert, width: 80, height: 80, color: AppColors.redBack),
          AppGaps.h20,
          Text(
            LanguageService.get('error_loading_machines'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          AppGaps.h10,
          Text(model.errorMessage, style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
          AppGaps.h20,
          ElevatedButton(
            onPressed: model.refreshMachines,
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

  Widget _buildEmptyState(BuildContext context, MachineSupplierViewModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppImages.myCustomers, width: 80, height: 80, color: AppColors.gray),
          AppGaps.h20,
          Text(LanguageService.get('no_machines_found'), style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildMachineCard(Datum datum, MachineSupplierViewModel model, BuildContext context) {
    final customer = datum.customer;
    final organization = model.getOrganizationForMachine(datum);
    final firstMachine = customer?.machines?.isNotEmpty == true ? customer!.machines!.first : null;

    return InkWell(
      onTap: () => model.onMachineTap(context, datum),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(color: AppColors.lavenderMist, borderRadius: BorderRadius.circular(14)),
                  padding: EdgeInsets.all(16),
                  child: Text(
                    customer?.countryOrigin ?? "N/A",
                    style: const TextStyle(color: AppColors.colorBlue, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: ClipRRect(borderRadius: BorderRadius.circular(2), child: Image.asset(AppImages.flag, height: 16, width: 16)),
                ),
              ],
            ),

            AppGaps.w16,

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    organization?.fullName ?? customer?.customerName ?? "N/A",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  Text(
                    firstMachine?.machine?.remarks ?? customer?.contactPerson ?? "N/A",
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            AppGaps.w16,

            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.softGray,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.textGray.withValues(alpha: 0.1)),
              ),
              child: Image.asset(AppImages.arrowRight, width: 16, height: 16, color: AppColors.darkGray),
            ),
          ],
        ),
      ),
    );
  }
}
