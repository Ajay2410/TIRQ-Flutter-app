import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:manager/core/models/customer.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/services/customer.service.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/features/home/my_customers/machine_details/customer_machine_details.view.dart';
import 'package:manager/features/home/my_customers/machine_details/customer_details/customer_edit_details.view.dart';
import 'package:manager/features/home/my_customers/create_customer/create_new_customer.view.dart';
import 'package:stacked/stacked.dart';
import 'package:shimmer/shimmer.dart';
import 'customer_details.vm.dart';

class CustomerDetailsView extends StatefulWidget {
  final String customerId;

  const CustomerDetailsView({super.key, required this.customerId});

  @override
  State<CustomerDetailsView> createState() => _CustomerDetailsViewState();
}

class _CustomerDetailsViewState extends State<CustomerDetailsView> {
  bool _isDeleting = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final CustomerService _customerService = locator<CustomerService>();

  @override
  void initState() {
    super.initState();
  }

  void _navigateToEditCustomer(CustomerDetailsViewModel model) async {
    final customer = model.customer;
    if (customer?.id == null) return;

    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => CreateNewCustomerView(isEditMode: true, customerId: customer!.id!)));

    if (result != null && result is Customer) {
      model.refreshCustomerDetails();
      model.markAsChanged();

      if (mounted) {
        _scaffoldKey.currentState?.showSnackBar(
          SnackBar(content: Text('Customer updated successfully'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CustomerDetailsViewModel>.reactive(
      viewModelBuilder: () => CustomerDetailsViewModel(),
      onViewModelReady: (CustomerDetailsViewModel model) => model.init(widget.customerId),
      disposeViewModel: false,
      builder: (BuildContext context, CustomerDetailsViewModel model, Widget? child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              Navigator.of(context).pop(model.hasChanges);
            }
          },
          child: AbsorbPointer(
            absorbing: _isDeleting,
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppColors.scaffoldBackground,
              appBar: _buildAppBar(context, model),
              body: Stack(
                children: [
                  Column(
                    children: [
                      Padding(padding: const EdgeInsets.all(12), child: _buildCustomerContactCard(model)),
                      Expanded(
                        child: Container(
                          color: AppColors.scaffoldBackground,
                          padding: const EdgeInsets.all(12),
                          child: SingleChildScrollView(child: _buildMachineList(context, model)),
                        ),
                      ),
                    ],
                  ),
                  if (_isDeleting) Positioned.fill(child: Center(child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))),
                ],
              ),
              floatingActionButton: _buildFloatingActionButton(context, model),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, CustomerDetailsViewModel model) {
    final customer = model.customer;

    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white),
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
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.colorF0F2FC),
            child: Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(color: AppColors.bluebackground, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  customer?.customerName?.substring(0, 2).toUpperCase() ?? 'NA',
                  style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer?.customerName ?? 'Loading...',
                  style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  customer?.designation?.isNotEmpty == true ? customer!.designation! : 'customer'.lang,
                  style: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          menuPadding: EdgeInsets.zero,
          offset: const Offset(-10, 30),
          onSelected: (String value) {
            if (value == 'edit') {
              _navigateToEditCustomer(model);
            } else if (value == 'delete') {
              _showDeleteConfirmation(context, model);
            }
          },
          itemBuilder:
              (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('edit'.lang, style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('delete'.lang, style: const TextStyle(color: AppColors.redBack, fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: AppColors.white,
          shadowColor: AppColors.black.withValues(alpha: 0.1),
          child: const Icon(Icons.more_vert, color: AppColors.white, size: 24),
        ),
      ],
    );
  }

  Widget _buildCustomerContactCard(CustomerDetailsViewModel model) {
    if (model.isBusy) {
      return _buildShimmerContactCard();
    }

    if (model.hasError) {
      return _buildErrorState(model);
    }

    final customer = model.customer;
    if (customer == null) {
      return _buildEmptyState();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.colorF0F2FC,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContactInfoRow(
                  'contact_person'.lang,
                  customer.contactPerson?.isNotEmpty == true ? customer.contactPerson! : 'not_available'.lang,
                ),
                const SizedBox(height: 12),
                _buildContactInfoRow('email'.lang, customer.email?.isNotEmpty == true ? customer.email! : 'not_available'.lang),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContactInfoRow('designation'.lang, customer.designation?.isNotEmpty == true ? customer.designation! : 'not_available'.lang),
                const SizedBox(height: 12),
                _buildContactInfoRow('phone'.lang, customer.phoneNumber?.isNotEmpty == true ? customer.phoneNumber! : 'not_available'.lang),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildMachineList(BuildContext context, CustomerDetailsViewModel model) {
    if (model.isBusy) {
      return _buildShimmerMachineList();
    }

    if (model.hasError) {
      return _buildErrorState(model);
    }

    final customer = model.customer;
    if (customer == null) {
      return _buildEmptyState();
    }

    if (customer.machines?.isEmpty != false) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppImages.myCustomers, width: 80, height: 80, color: AppColors.gray),
            const SizedBox(height: 20),
            Text('no_machines_assigned'.lang, style: TextStyle(fontSize: 18, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Text('this_customer_has_no_machines'.lang, style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return Column(children: customer.machines!.map((machineData) => _buildMachineCard(context, machineData, customer, model)).toList());
  }

  Widget _buildMachineCard(BuildContext context, MachineElement machineData, Customer customer, CustomerDetailsViewModel model) {
    final machine = machineData.machine;
    if (machine == null) return const SizedBox.shrink();

    final machineName = machine.machineName ?? 'Unknown Machine';
    final modelNumber = machine.modelNumber ?? 'N/A';
    final machineType = machine.machineType ?? 'Unknown Type';
    final isInWarranty = machineData.warrantyStatus == 'In warranty';
    final country = customer.countryOrigin?.isNotEmpty == true ? customer.countryOrigin! : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(color: AppColors.colorF0F2FC, borderRadius: BorderRadius.circular(16)),
                child: Text(country, style: TextStyle(color: AppColors.colorBlue, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(machineName, style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold))),

              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isInWarranty ? AppColors.success.withValues(alpha: 0.15) : AppColors.redBack.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isInWarranty ? "In warranty" : "Out Of Warranty",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isInWarranty ? AppColors.success : AppColors.redBack),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => CustomerMachineDetailsView(customer: customer, machineElement: machineData)));

                  if (result != null && result is Customer) {
                    model.refreshCustomerDetails();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.softGray,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.textGrey.withValues(alpha: 0.1)),
                  ),
                  child: Image.asset(AppImages.arrowRight, width: 16, height: 16, color: AppColors.darkGray),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.lightGrey),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMachineInfoRow('model_number'.lang, modelNumber)),
              const SizedBox(width: 24),
              Expanded(child: _buildMachineInfoRow('machine_type'.lang, machineType)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMachineInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, CustomerDetailsViewModel model) {
    final customer = model.customer;
    if (customer == null) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      onPressed: () async {
        final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => CustomerEditDetailsView(customer: customer)));

        if (result != null && result is Customer) {
          model.refreshCustomerDetails();
          model.markAsChanged();

          if (mounted) {
            _scaffoldKey.currentState?.showSnackBar(
              SnackBar(content: Text('Customer updated successfully'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
            );
          }
        }
      },
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      icon: const Icon(Icons.add, size: 20),
      label: Text('assign_new_machine'.lang, style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CustomerDetailsViewModel model) {
    final customer = model.customer;
    if (customer?.id == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context1) {
        return Dialog(
          insetPadding: EdgeInsets.all(10),
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.redBack.withValues(alpha: 0.1)),
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.redBack),
                    child: const Center(child: Text('!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
                  ),
                ),
                const SizedBox(height: 15),

                Text(
                  'are_you_sure_remove_customer'.lang,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500, height: 1.3),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.darkGray,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          side: BorderSide(color: AppColors.darkGray, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('cancel'.lang, style: TextStyle(color: AppColors.darkGray, fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _isDeleting
                                ? null
                                : () {
                                  Navigator.of(context1).pop();
                                  _handleDeleteCustomer(context, model);
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.redBack,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child:
                            _isDeleting
                                ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                )
                                : Text('remove'.lang, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.center,
                  child: Text('remove_customer_warning'.lang, style: TextStyle(color: AppColors.redBack, fontSize: 12, fontWeight: FontWeight.w400)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleDeleteCustomer(BuildContext context, CustomerDetailsViewModel model) async {
    if (_isDeleting) return;

    final customer = model.customer;
    if (customer?.id == null) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      if (customer!.id!.isEmpty) {
        Fluttertoast.showToast(
          msg: 'invalid_machine_id'.lang,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.redBack,
          textColor: AppColors.white,
          fontSize: 16,
        );
        return;
      }

      final result = await _customerService.deleteCustomer(customer.id!);

      result.fold(
        (failure) {
          Fluttertoast.showToast(
            msg: failure.message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: AppColors.redBack,
            textColor: AppColors.white,
            fontSize: 16,
          );
        },
        (success) {
          Fluttertoast.showToast(
            msg: 'machine_removed_successfully'.lang,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: AppColors.success,
            textColor: AppColors.white,
            fontSize: 16,
          );

          Get.back(result: true);
        },
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'unexpected_error_occurred'.lang,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.redBack,
        textColor: AppColors.white,
        fontSize: 16,
      );
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  Widget _buildShimmerContactCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey,
      highlightColor: AppColors.white,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.colorF0F2FC,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: 80, color: AppColors.lightGrey),
                  const SizedBox(height: 4),
                  Container(height: 14, width: 120, color: AppColors.lightGrey),
                  const SizedBox(height: 12),
                  Container(height: 12, width: 40, color: AppColors.lightGrey),
                  const SizedBox(height: 4),
                  Container(height: 14, width: 150, color: AppColors.lightGrey),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: 70, color: AppColors.lightGrey),
                  const SizedBox(height: 4),
                  Container(height: 14, width: 100, color: AppColors.lightGrey),
                  const SizedBox(height: 12),
                  Container(height: 12, width: 35, color: AppColors.lightGrey),
                  const SizedBox(height: 4),
                  Container(height: 14, width: 130, color: AppColors.lightGrey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerMachineList() {
    return Column(children: List.generate(3, (index) => _buildShimmerMachineCard()));
  }

  Widget _buildShimmerMachineCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey,
      highlightColor: AppColors.white,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(16)),
                  child: Container(height: 14, width: 20, color: AppColors.lightGrey),
                ),
                const SizedBox(width: 12),
                Expanded(child: Container(height: 16, color: AppColors.lightGrey)),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(6)),
                  child: Container(height: 12, width: 50, color: AppColors.lightGrey),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(10)),
                  child: Container(height: 16, width: 16, color: AppColors.lightGrey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: AppColors.lightGrey),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 12, width: 80, color: AppColors.lightGrey),
                      const SizedBox(height: 4),
                      Container(height: 12, width: 100, color: AppColors.lightGrey),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 12, width: 70, color: AppColors.lightGrey),
                      const SizedBox(height: 4),
                      Container(height: 12, width: 120, color: AppColors.lightGrey),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(CustomerDetailsViewModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppImages.alert, width: 80, height: 80, color: AppColors.redBack),
          const SizedBox(height: 20),
          Text('Error loading customer details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Text(model.errorMessage, style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => model.refreshCustomerDetails(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('retry'.lang),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppImages.myCustomers, width: 80, height: 80, color: AppColors.gray),
          const SizedBox(height: 20),
          Text('No customer details found', style: TextStyle(fontSize: 18, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
