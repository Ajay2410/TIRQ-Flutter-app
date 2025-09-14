import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/services/machine_storage.service.dart';
import 'package:manager/core/locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:manager/routes/routes.dart';
import 'package:manager/features/home/machine_records/add_new_machine_model.view.dart';
import 'package:manager/core/models/machine_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MachineRecordsView extends StatefulWidget {
  final bool refreshOnInit;

  const MachineRecordsView({super.key, this.refreshOnInit = false});

  @override
  State<MachineRecordsView> createState() => _MachineRecordsViewState();
}

class _MachineRecordsViewState extends State<MachineRecordsView> with TickerProviderStateMixin {
  final MachineStorageService _machineStorageService = MachineStorageService();
  final _navigationService = locator<NavigationService>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  List<Datum> _machines = [];
  List<Datum> _filteredMachines = [];
  bool _isLoading = false;
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

    if (widget.refreshOnInit) {
      _refreshMachines();
    } else {
      _loadMachines(isUpdate: true);
    }
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
      _clearSearch();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _filteredMachines = _machines;
    setState(() {});
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      _filteredMachines = _machines;
    } else {
      _filteredMachines =
          _machines.where((machine) {
            final searchLower = query.toLowerCase();
            return machine.machineName?.toLowerCase().contains(searchLower) == true ||
                machine.modelNumber?.toLowerCase().contains(searchLower) == true ||
                machine.machineType?.toLowerCase().contains(searchLower) == true ||
                machine.remarks?.toLowerCase().contains(searchLower) == true;
          }).toList();
    }
    setState(() {});
  }

  Future<void> _loadMachines({bool isUpdate = false}) async {
    setState(() {
      _machines = [];
      _isLoading = true;
    });

    try {
      await _machineStorageService.initializeMachines(isUpdate: isUpdate);
      final machines = await _machineStorageService.getMachines();
      setState(() {
        _machines = machines;
        _filteredMachines = machines;
      });
    } catch (e) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshMachines() async {
    await _machineStorageService.refreshMachines();
    final machines = await _machineStorageService.getMachines();
    setState(() {
      _machines = machines;
      _filteredMachines = machines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Container(
                color: AppColors.scaffoldBackground,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SlideTransition(position: _slideAnimation, child: _isSearchVisible ? _buildSearchBar(context) : const SizedBox.shrink()),
                    Expanded(
                      child:
                          _isLoading
                              ? RefreshIndicator(
                                onRefresh: _refreshMachines,
                                backgroundColor: AppColors.white,
                                child: SingleChildScrollView(child: _buildShimmerList()),
                              )
                              : RefreshIndicator(
                                backgroundColor: AppColors.white,
                                onRefresh: _refreshMachines,
                                child: SingleChildScrollView(child: _buildMachineList(context)),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: IconButton(icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white), onPressed: () => Get.back()),
      titleSpacing: 0,
      title: Text('machine_records'.lang, style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      actions: [IconButton(icon: Image.asset(AppImages.search, width: 24, height: 24, color: AppColors.white), onPressed: _toggleSearch)],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.white,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'search_machines'.lang,
          prefixIcon: Padding(padding: const EdgeInsets.all(16), child: Image.asset(AppImages.search, width: 20, height: 20, color: AppColors.gray)),
          suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: Icon(Icons.clear, color: AppColors.gray), onPressed: _clearSearch) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.lightGray)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary)),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildMachineList(BuildContext context) {
    if (_filteredMachines.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.precision_manufacturing, size: 64, color: AppColors.textGray),
              const SizedBox(height: 16),
              Text(
                _searchController.text.isNotEmpty ? 'no_machines_found_search'.lang : 'no_machines_found'.lang,
                style: TextStyle(color: AppColors.textGray, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: _filteredMachines.map((machine) => _buildMachineCard(context, machine)).toList());
  }

  Widget _buildMachineCard(BuildContext context, Datum machine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(color: AppColors.colorF0F2FC, borderRadius: BorderRadius.circular(16)),
            child: Text(
              machine.machineType?.substring(0, 2).toUpperCase() ?? 'NA',
              style: TextStyle(color: AppColors.colorBlue, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "#${machine.machineName} - ${machine.machineName}",
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text("${"add_on".lang}: ", style: TextStyle(color: AppColors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        machine.remarks ?? 'No add-ons',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final result = await _navigationService.navigateTo(Routes.machineDetails, arguments: machine);

              if (result == true) {
                await _loadMachines(isUpdate: true);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.softGray,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.textGray.withValues(alpha: 0.1)),
              ),
              child: Image.asset(AppImages.arrowRight, width: 16, height: 16, color: AppColors.darkGray),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineCardShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 18,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(width: 60, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(width: 8),
                      Expanded(child: Container(height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return RefreshIndicator(
      onRefresh: _refreshMachines,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(children: List.generate(6, (index) => _buildMachineCardShimmer())),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Builder(
      builder:
          (context) => FloatingActionButton.extended(
            onPressed: () async {
              final result = await Get.to(() => const AddNewMachineModelView());

              if (result != null && result is Datum) {
                await _refreshMachines();

                Fluttertoast.showToast(
                  msg: 'Machine created successfully!',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 3,
                  backgroundColor: AppColors.success,
                  textColor: Colors.white,
                  fontSize: 16,
                );
              }
            },
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            icon: const Icon(Icons.add, size: 20),
            label: Text('add_new_models'.lang, style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
    );
  }
}
