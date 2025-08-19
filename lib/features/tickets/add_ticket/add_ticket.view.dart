import 'package:flutter/material.dart';
import 'package:manager/core/models/machine.dart';
import 'package:manager/core/models/relationships.dart';
import 'package:stacked/stacked.dart';

import '../../../resources/app_resources/app_resources.dart';
import '../../../services/language.service.dart';
import 'add_ticket.vm.dart';

class AddTicketViewAttributes {
  final Machine? machine;
  AddTicketViewAttributes({this.machine});
}

class AddTicketView extends StatelessWidget {
  const AddTicketView({super.key, required this.attributes});

  final AddTicketViewAttributes attributes;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddTicketViewModel>.reactive(
      viewModelBuilder: () => AddTicketViewModel(),
      onViewModelReady:
          (AddTicketViewModel model) => model.init(attributes.machine),
      disposeViewModel: false,
      builder: (BuildContext context, AddTicketViewModel model, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            surfaceTintColor: AppColors.primary,
            iconTheme: IconThemeData(color: AppColors.white),

            title: RichText(
              text: TextSpan(
                text: LanguageService.get("create_ticket"),
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(color: AppColors.white),
              ),
            ),
          ),
          body:
              model.isBusy || model.isLoadingRelationships
                  ? Center(child: CircularProgressIndicator(color: AppColors.primary,),)
                  : model.availableRelationships.isEmpty?_buildEmptyState(context, model):Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.w30),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Form(
                        key: model.formKey,
                        child: Column(
                          spacing: AppSizes.h6,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: AppSizes.h10,
                              children: [
                                SizedBox(height: AppSizes.h10),
                                Text(
                                  LanguageService.get("facing_machine_problem"),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                bottom: AppSizes.h10,
                                top: AppSizes.h10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.v14,
                                ),
                                border: Border(
                                  left: BorderSide(
                                    color: AppColors.primary,
                                    width: AppSizes.w4,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: AppSizes.w10,
                                      top: AppSizes.h10,
                                    ),
                                    child: Text(
                                      LanguageService.get("select_manufacturer"),
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleSmall,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(AppSizes.h10),
                                    child:
                                        model.isLoadingRelationships
                                            ? Center(
                                              child: SizedBox(
                                                height: AppSizes.h24,
                                                width: AppSizes.h24,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            )
                                            : DropdownButtonFormField<
                                              Relationship
                                            >(
                                              value: model.relationship,
                                              decoration: InputDecoration(
                                                hintText:
                                                LanguageService.get("select_manufacturer"),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: AppSizes.w16,
                                                      vertical: AppSizes.h12,
                                                    ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        AppSizes.v8,
                                                      ),
                                                ),
                                              ),
                                              validator:
                                                  (value) =>
                                                      value == null
                                                          ?  LanguageService.get("please_select_a_machine")
                                                          : null,
                                              items:
                                                  model.availableRelationships.map((
                                                    Relationship relationship,
                                                  ) {
                                                    return DropdownMenuItem<
                                                      Relationship
                                                    >(
                                                      value: relationship,
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            height:
                                                                AppSizes.h28,
                                                            width: AppSizes.h28,
                                                            decoration: BoxDecoration(
                                                              color: AppColors
                                                                  .primary
                                                                  .withValues(
                                                                    alpha: 0.1,
                                                                  ),
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                            ),
                                                            child: Icon(
                                                              Icons
                                                                  .precision_manufacturing,
                                                              color:
                                                                  AppColors
                                                                      .primary,
                                                              size:
                                                                  AppSizes.h14,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: AppSizes.w8,
                                                          ),
                                                          Flexible(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Text(
                                                                  relationship
                                                                          .partnerName ??
                                                                      'Unnamed Manufacturer',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        AppSizes
                                                                            .v13,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                Text(
                                                                  'ID: ${relationship.partnerId ?? 'N/A'}',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        AppSizes
                                                                            .v11,
                                                                    color:
                                                                        AppColors
                                                                            .textSecondary,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                              onChanged: (
                                                Relationship? newValue,
                                              ) {
                                                model.selectRelationship(
                                                  newValue,
                                                );
                                              },
                                              isExpanded: true,
                                              selectedItemBuilder: (
                                                BuildContext context,
                                              ) {
                                                return model
                                                    .availableRelationships
                                                    .map<Widget>((
                                                      Relationship machine,
                                                    ) {
                                                      return Container(
                                                        alignment:
                                                            Alignment
                                                                .centerLeft,
                                                        constraints:
                                                            BoxConstraints(
                                                              minWidth: 100,
                                                            ),
                                                        child: Text(
                                                          machine.partnerName ??
                                                              'Unnamed Manufacturer',
                                                          style: TextStyle(
                                                            color:
                                                                AppColors
                                                                    .textPrimary,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      );
                                                    })
                                                    .toList();
                                              },
                                              icon: Icon(
                                                Icons.arrow_drop_down,
                                                color: AppColors.primary,
                                              ),
                                              dropdownColor:
                                                  Theme.of(
                                                    context,
                                                  ).scaffoldBackgroundColor,
                                              menuMaxHeight: 350,
                                              isDense: true,
                                            ),
                                  ),
                                ],
                              ),
                            ),
                            if (model.relationship != null)
                              Container(
                                margin: EdgeInsets.only(
                                  bottom: AppSizes.h10,
                                  top: AppSizes.h10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.v14,
                                  ),
                                  border: Border(
                                    left: BorderSide(
                                      color: AppColors.primary,
                                      width: AppSizes.w4,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: AppSizes.w10,
                                        top: AppSizes.h10,
                                      ),
                                      child: Text(
                                        LanguageService.get("select_machine"),
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleSmall,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(AppSizes.h10),
                                      child:
                                          model.isLoadingMachines
                                              ? Center(
                                                child: SizedBox(
                                                  height: AppSizes.h24,
                                                  width: AppSizes.h24,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: AppColors.primary,
                                                      ),
                                                ),
                                              )
                                              : model.availableMachines.isEmpty
                                              ? Container(
                                            padding: EdgeInsets.all(AppSizes.h16),
                                            decoration: BoxDecoration(
                                              color: AppColors.lightGray.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(AppSizes.v8),
                                              border: Border.all(
                                                color: AppColors.lightGray,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.info_outline,
                                                  color: AppColors.gray,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                   LanguageService.get("no_machines_available_manufacturer"),
                                                    style: TextStyle(
                                                      color: AppColors.gray,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                              : DropdownButtonFormField<
                                                Machine
                                              >(
                                                value: model.machine,
                                                decoration: InputDecoration(
                                                  hintText: LanguageService.get("select_machine"),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                        horizontal:
                                                            AppSizes.w16,
                                                        vertical: AppSizes.h12,
                                                      ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          AppSizes.v8,
                                                        ),
                                                  ),
                                                ),
                                                validator:
                                                    (value) =>
                                                        value == null
                                                            ? LanguageService.get("please_select_a_machine")
                                                            : null,
                                                items:
                                                    model.availableMachines.map((
                                                      Machine machine,
                                                    ) {
                                                      return DropdownMenuItem<
                                                        Machine
                                                      >(
                                                        value: machine,
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Container(
                                                              height:
                                                                  AppSizes.h28,
                                                              width:
                                                                  AppSizes.h28,
                                                              decoration: BoxDecoration(
                                                                color: AppColors
                                                                    .primary
                                                                    .withValues(
                                                                      alpha:
                                                                          0.1,
                                                                    ),
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                              child: Icon(
                                                                Icons
                                                                    .precision_manufacturing,
                                                                color:
                                                                    AppColors
                                                                        .primary,
                                                                size:
                                                                    AppSizes
                                                                        .h14,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  AppSizes.w8,
                                                            ),
                                                            Flexible(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(
                                                                    machine.machineName ??
                                                                        'Unnamed Machine',
                                                                    style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          AppSizes
                                                                              .v13,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                  Text(
                                                                    'S/N: ${machine.serialNumber ?? 'N/A'}',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          AppSizes
                                                                              .v11,
                                                                      color:
                                                                          AppColors
                                                                              .textSecondary,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                onChanged: (Machine? newValue) {
                                                  model.selectMachine(newValue);
                                                },
                                                isExpanded: true,
                                                selectedItemBuilder: (
                                                  BuildContext context,
                                                ) {
                                                  return model.availableMachines.map<
                                                    Widget
                                                  >((Machine machine) {
                                                    return Container(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      constraints:
                                                          BoxConstraints(
                                                            minWidth: 100,
                                                          ),
                                                      child: Text(
                                                        machine.machineName ??
                                                            'Unnamed Machine',
                                                        style: TextStyle(
                                                          color:
                                                              AppColors
                                                                  .textPrimary,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    );
                                                  }).toList();
                                                },
                                                icon: Icon(
                                                  Icons.arrow_drop_down,
                                                  color: AppColors.primary,
                                                ),
                                                dropdownColor:
                                                    Theme.of(
                                                      context,
                                                    ).scaffoldBackgroundColor,
                                                menuMaxHeight: 350,
                                                isDense: true,
                                              ),
                                    ),
                                  ],
                                ),
                              ),

                            if (model.machine != null)
                              Container(
                                margin: EdgeInsets.only(bottom: AppSizes.h20),
                                padding: EdgeInsets.all(AppSizes.h15),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      AppColors.lightGray.withValues(alpha: 0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(AppSizes.v14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      blurRadius: 15,
                                      offset: Offset(0, 5),
                                      spreadRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header with Machine Name
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${model.machine?.machineName}-${model.machine?.modelNumber}',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: AppSizes.h10),
                                    // Enhanced Warranty Status with Prominent Highlighting
                                    Container(
                                      padding: EdgeInsets.all(AppSizes.h16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            _getWarrantyStatusColor(model.machine?.warranty),
                                            _getWarrantyStatusColor(model.machine?.warranty).withValues(alpha: 0.8),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(AppSizes.v12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _getWarrantyStatusColor(model.machine?.warranty).withValues(alpha: 0.3),
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Prominent Status Header
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(AppSizes.h8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(AppSizes.v8),
                                                ),
                                                child: Icon(
                                                  _getWarrantyIcon(model.machine?.warranty),
                                                  color: Colors.white,
                                                  size: AppSizes.v18,
                                                ),
                                              ),
                                              SizedBox(width: AppSizes.h10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      LanguageService.get("warranty_status"),
                                                      style: TextStyle(
                                                        fontSize: AppSizes.v12,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.white.withValues(alpha: 0.9),
                                                        letterSpacing: 1.0,
                                                      ),
                                                    ),
                                                    Text(
                                                      (model.machine?.warranty?.status ?? "Unknown").toUpperCase(),
                                                      style: TextStyle(
                                                        fontSize: AppSizes.v16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),

                                          if (_isWarrantyActive(model.machine?.warranty))
                                            Padding(
                                              padding: EdgeInsets.only(top: AppSizes.h12),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: AppSizes.h12,
                                                  vertical: AppSizes.h6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(AppSizes.v6),
                                                ),
                                                child: Text(
                                                  '${_getDaysRemaining(model.machine?.warranty?.expirationDate)} days remaining',
                                                  style: TextStyle(
                                                    fontSize: AppSizes.v13,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),

                                          SizedBox(height: AppSizes.h15),

                                          // Warranty Details in organized rows
                                          _buildWarrantyField(LanguageService.get("invoice_no"), model.machine?.warranty?.invoiceNo ?? "N/A"),
                                          SizedBox(height: AppSizes.h8),

                                          // Purchase and Installation Dates
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildWarrantyField(
                                                  LanguageService.get("purchase_date"),
                                                  _formatDate(model.machine?.warranty?.purchaseDate),
                                                ),
                                              ),
                                              Expanded(
                                                child: _buildWarrantyField(
                                                  LanguageService.get("installation_date"),
                                                  _formatDate(model.machine?.warranty?.installationDate),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: AppSizes.h8),

                                          // Start and Expiration Dates
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildWarrantyField(
                                                  LanguageService.get("start_date"),
                                                  _formatDate(model.machine?.warranty?.startDate),
                                                ),
                                              ),
                                              Expanded(
                                                child: _buildWarrantyField(
                                                 LanguageService.get("expiration_date"),
                                                  _formatDate(model.machine?.warranty?.expirationDate),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Ticket type selector
                            Container(
                              margin: EdgeInsets.only(bottom: AppSizes.h10),
                              padding: EdgeInsets.symmetric(
                                vertical: AppSizes.h10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.v14,
                                ),
                                border: Border(
                                  left: BorderSide(
                                    color: AppColors.primary,
                                    width: AppSizes.w4,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: AppSizes.w10,
                                    ),
                                    child: Text(
                                     LanguageService.get("ticket_type"),
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ),
                                  SizedBox(height: AppSizes.h6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _ticketTypeButton(
                                        context,
                                        model,
                                        "Repair",
                                      ),
                                      _ticketTypeButton(
                                        context,
                                        model,
                                        "Maintenance",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            if (model.ticketType == "Maintenance")
                              Container(
                                margin: EdgeInsets.only(bottom: AppSizes.h10),
                                padding: EdgeInsets.symmetric(vertical: AppSizes.h10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppSizes.v14),
                                  border: Border(
                                    left: BorderSide(
                                      color: AppColors.primary,
                                      width: AppSizes.w4,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: AppSizes.w10),
                                      child: Text(
                                        LanguageService.get("maintenance_type"),
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                    ),
                                    SizedBox(height: AppSizes.h10),

                                    // General Checkup Radio Button
                                    RadioListTile<MaintenanceType>(

                                      title: Text(
                                        LanguageService.get("general_checkup"),
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                       LanguageService.get("basic_inspection_adjustments"),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      value: MaintenanceType.generalCheckup,
                                      groupValue: model.selectedMaintenanceType,
                                      onChanged: (MaintenanceType? value) {
                                        model.setMaintenanceType(value);
                                      },
                                      fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                                        if (states.contains(MaterialState.selected)) {
                                          return AppColors.primary; // Active color
                                        }
                                        return AppColors.gray; // Inactive color - change this to your desired color
                                      }),
                                      activeColor: AppColors.primary,
                                      contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.w10),
                                    ),

                                    // Full Machine Service Radio Button
                                    RadioListTile<MaintenanceType>(

                                      title: Text(
                                        LanguageService.get("full_machine_service"),
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        LanguageService.get("comprehensive_service_maintenance"),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      value: MaintenanceType.fullMachineService,
                                      groupValue: model.selectedMaintenanceType,
                                      onChanged: (MaintenanceType? value) {
                                        model.setMaintenanceType(value);
                                      },
                                      fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                                        if (states.contains(MaterialState.selected)) {
                                          return AppColors.primary; // Active color
                                        }
                                        return AppColors.gray; // Inactive color - change this to your desired color
                                      }),
                                      activeColor: AppColors.primary,
                                      contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.w10),
                                    ),
                                  ],
                                ),
                              ),

                            if (model.ticketType == "Maintenance" &&
                                model.selectedMaintenanceType != null &&
                                model.warrantyMessage.isNotEmpty)
                              Container(
                                margin: EdgeInsets.only(bottom: AppSizes.h20),
                                padding: EdgeInsets.all(AppSizes.h16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      model.requiresPayment
                                          ? Colors.orange.withValues(alpha: 0.1)
                                          : Colors.green.withValues(alpha: 0.1),
                                      model.requiresPayment
                                          ? Colors.orange.withValues(alpha: 0.05)
                                          : Colors.green.withValues(alpha: 0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(AppSizes.v12),
                                  border: Border.all(
                                    color: model.requiresPayment
                                        ? Colors.orange.withValues(alpha: 0.3)
                                        : Colors.green.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(AppSizes.h8),
                                          decoration: BoxDecoration(
                                            color: model.requiresPayment
                                                ? Colors.orange.withValues(alpha: 0.2)
                                                : Colors.green.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(AppSizes.v8),
                                          ),
                                          child: Icon(
                                            model.requiresPayment
                                                ? Icons.payment
                                                : Icons.check_circle_outline,
                                            color: model.requiresPayment
                                                ? Colors.orange[700]
                                                : Colors.green[700],
                                            size: AppSizes.v20,
                                          ),
                                        ),
                                        SizedBox(width: AppSizes.w12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                model.requiresPayment
                                                    ? LanguageService.get("service_charge_required")
                                                    : LanguageService.get("no_charge"),
                                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                  color: model.requiresPayment
                                                      ? Colors.orange[700]
                                                      : Colors.green[700],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (model.requiresPayment)
                                                Text(
                                                  "\$${model.serviceCharge.toStringAsFixed(2)} USD",
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    color: Colors.orange[800],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: AppSizes.h12),
                                    Text(
                                      model.warrantyMessage,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textPrimary,
                                        height: 1.4,
                                      ),
                                    ),
                                    if (model.requiresPayment)
                                      Padding(
                                        padding: EdgeInsets.only(top: AppSizes.h12),
                                        child: Container(
                                          padding: EdgeInsets.all(AppSizes.h10),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(AppSizes.v8),
                                            border: Border.all(
                                              color: Colors.orange.withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: Colors.orange[700],
                                                size: AppSizes.v16,
                                              ),
                                              SizedBox(width: AppSizes.w8),
                                              Expanded(
                                                child: Text(
                                                  LanguageService.get("payment_processed_before_scheduling"),
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Colors.orange[700],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.v14,
                                ),
                                border: Border(
                                  left: BorderSide(
                                    color: AppColors.primary,
                                    width: AppSizes.w4,
                                  ),
                                ),
                              ),
                              child: TextFormField(
                                controller: model.problemController,
                                textInputAction: TextInputAction.next,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  label: Text(
                                    LanguageService.get("describe_problem"),
                                  ),
                                ),
                                validator:
                                    (value) =>
                                        value?.isEmpty == true
                                            ? LanguageService.get("please_describe_the_problem")
                                            : null,
                              ),
                            ),

                            SizedBox(height: AppSizes.h10),

                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.v14,
                                ),
                                border: Border(
                                  left: BorderSide(
                                    color: AppColors.primary,
                                    width: AppSizes.w4,
                                  ),
                                ),
                              ),
                              child: TextFormField(
                                controller: model.errorCodeController,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  label: Text(
                                    LanguageService.get("error_code_if_available"),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: AppSizes.h10),

                            // File upload progress indicator
                            if (model.isUploading)
                              Padding(
                                padding: EdgeInsets.only(bottom: AppSizes.h20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      LanguageService.get("uploading_files"),
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleSmall,
                                    ),
                                    SizedBox(height: AppSizes.h10),
                                    LinearProgressIndicator(
                                      value: model.uploadProgress,
                                      backgroundColor: AppColors.lightGray,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(height: AppSizes.h4),
                                    Text(
                                      "${(model.uploadProgress * 100).toInt()}%",
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),

                            // Selected local files (not yet uploaded)
                            if (model.localFiles.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(bottom: AppSizes.h20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                     "${LanguageService.get("selected_files")}(${model.localFiles.length})",
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleSmall,
                                    ),
                                    SizedBox(height: AppSizes.h10),
                                    Wrap(
                                      spacing: AppSizes.w10,
                                      runSpacing: AppSizes.h10,
                                      children: List.generate(model.localFiles.length, (
                                        index,
                                      ) {
                                        final file = model.localFiles[index];
                                        final filename =
                                            file.path.split('/').last;
                                        final isImage =
                                            filename.toLowerCase().endsWith(
                                              '.jpg',
                                            ) ||
                                            filename.toLowerCase().endsWith(
                                              '.jpeg',
                                            ) ||
                                            filename.toLowerCase().endsWith(
                                              '.png',
                                            );

                                        return Stack(
                                          children: [
                                            Container(
                                              height: AppSizes.h80,
                                              width: AppSizes.w80,
                                              decoration: BoxDecoration(
                                                color: AppColors.lightGray,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppSizes.v8,
                                                    ),
                                                border: Border.all(
                                                  color: AppColors.gray
                                                      .withValues(alpha: 0.5),
                                                ),
                                              ),
                                              child: Center(
                                                child:
                                                    isImage
                                                        ? ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                AppSizes.v8,
                                                              ),
                                                          child: Image.file(
                                                            file,
                                                            height:
                                                                AppSizes.h80,
                                                            width: AppSizes.w80,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )
                                                        : Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .insert_drive_file,
                                                              color:
                                                                  AppColors
                                                                      .primary,
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  AppSizes.h4,
                                                            ),
                                                            Text(
                                                              filename.length >
                                                                      8
                                                                  ? '${filename.substring(0, 5)}...'
                                                                  : filename,
                                                              style: TextStyle(
                                                                fontSize:
                                                                    AppSizes
                                                                        .v10,
                                                                color:
                                                                    AppColors
                                                                        .textSecondary,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: InkWell(
                                                onTap:
                                                    () => model.removeLocalFile(
                                                      index,
                                                    ),
                                                child: Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.error,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: AppColors.white,
                                                    size: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),

                            // Uploaded attachments
                            if (model.attachments.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(bottom: AppSizes.h20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                    "${LanguageService.get("uploaded_attachments")} (${model.attachments.length})",
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleSmall,
                                    ),
                                    SizedBox(height: AppSizes.h10),
                                    Wrap(
                                      spacing: AppSizes.w10,
                                      runSpacing: AppSizes.h10,
                                      children:
                                          model.attachments.map((url) {
                                            final isImage =
                                                url.toLowerCase().endsWith(
                                                  '.jpg',
                                                ) ||
                                                url.toLowerCase().endsWith(
                                                  '.jpeg',
                                                ) ||
                                                url.toLowerCase().endsWith(
                                                  '.png',
                                                );

                                            return Stack(
                                              children: [
                                                Container(
                                                  height: AppSizes.h80,
                                                  width: AppSizes.w80,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.lightGray,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          AppSizes.v8,
                                                        ),
                                                    border: Border.all(
                                                      color: AppColors.primary
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child:
                                                        isImage
                                                            ? Icon(
                                                              Icons.image,
                                                              color:
                                                                  AppColors
                                                                      .primary,
                                                            )
                                                            : Icon(
                                                              Icons.attach_file,
                                                              color:
                                                                  AppColors
                                                                      .primary,
                                                            ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: InkWell(
                                                    onTap:
                                                        () => model
                                                            .removeAttachment(
                                                              url,
                                                            ),
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                        4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.error,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.close,
                                                        color: AppColors.white,
                                                        size: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            if (model.attachments.length < 6)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.v14,
                                ),
                                border: Border(
                                  left: BorderSide(
                                    color: AppColors.primary,
                                    width: AppSizes.w4,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed:
                                          model.isUploading
                                              ? null
                                              : () => model.uploadImages(),
                                      icon: Icon(Icons.add_photo_alternate),
                                      label: Text(
                                        LanguageService.get("add_media"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: AppSizes.h20),

                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.v14,
                                ),
                                border: Border(
                                  left: BorderSide(
                                    color: AppColors.primary,
                                    width: AppSizes.w4,
                                  ),
                                ),
                              ),
                              child: TextFormField(
                                controller: model.additionalNoteController,
                                textInputAction: TextInputAction.done,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  label: Text(
                                    LanguageService.get("additional_notes"),
                                  ),
                                ),
                              ),
                            ),

                            ..._buildAdditionalInfoSections(context, model),
                            Padding(
                              padding: EdgeInsets.only(
                                top: AppSizes.h20,
                                bottom: AppSizes.h20,

                              ),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  height: 36,
                                  child: ElevatedButton.icon(
                                    onPressed: model.addNewInfoSection,
                                    icon: Icon(Icons.add, size: 18),
                                    label: Text(
                                      LanguageService.get("add_more_information"), style: TextStyle(fontSize: 14)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: AppColors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: AppSizes.h40),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gray.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, -5),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: AppSizes.h12,
                              ),
                              child: ElevatedButton(
                                onPressed: model.isBusy || model.isUploading
                                    ? null
                                    : (model.machine != null && model.problemController.text.isNotEmpty)
                                    ? model.onSave
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(double.infinity, AppSizes.h50),
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                  disabledBackgroundColor: AppColors.gray.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.v10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: AppSizes.h12,
                                  ),
                                ),
                                child: model.isBusy || model.isUploading
                                    ? SizedBox(
                                  height: AppSizes.h20,
                                  width: AppSizes.h20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                                    : Text(
                                 LanguageService.get("submit"),
                                  style: TextStyle(
                                    fontSize: AppSizes.v16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
        );
      },
    );
  }



  Widget _buildEmptyState(BuildContext context, AddTicketViewModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.v24),
            decoration: BoxDecoration(
              color: AppColors.lightGray.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.precision_manufacturing_outlined,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: AppSizes.h20),
          Text(
            LanguageService.get("no_machines_found"),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.h8),
          Text(
            LanguageService.get('atleast_one_machine_is_needed_to_create_a_ticket'),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  IconData _getWarrantyIcon(dynamic warranty) {
    if (warranty?.status == null) return Icons.help_outline_rounded;

    final status = warranty.status.toString().toLowerCase();
    switch (status) {
      case 'active':
      case 'valid':
        return Icons.verified_rounded;
      case 'expired':
        return Icons.cancel_rounded;
      case 'expiring':
      case 'warning':
        return Icons.warning_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Widget _ticketTypeButton(
    BuildContext context,
    AddTicketViewModel model,
    String type,
  ) {
    final bool isSelected = model.ticketType == type;

    return InkWell(
      onTap: () => model.setTicketType(type),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.w12,
          vertical: AppSizes.h8,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary
                  : AppColors.lightGray.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppSizes.v20),
        ),
        child: Text(
          type,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildWarrantyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.v10,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: AppSizes.v12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Color _getWarrantyStatusColor(dynamic warranty) {
    if (warranty == null) return Colors.grey;

    String status = warranty.status?.toLowerCase() ?? '';
    DateTime? expirationDate = warranty.expirationDate != null
        ? DateTime.parse(warranty.expirationDate)
        : null;

    if (status == 'active' && expirationDate != null) {
      if (DateTime.now().isBefore(expirationDate)) {
        return Colors.green; // In warranty
      }
    }

    return Colors.red; // Out of warranty or expired
  }

  bool _isWarrantyActive(dynamic warranty) {
    if (warranty == null) return false;

    String status = warranty.status?.toLowerCase() ?? '';
    DateTime? expirationDate = warranty.expirationDate != null
        ? DateTime.parse(warranty.expirationDate)
        : null;

    return status == 'active' &&
        expirationDate != null &&
        DateTime.now().isBefore(expirationDate);
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return "N/A";

    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return "Invalid Date";
    }
  }

  int _getDaysRemaining(String? expirationDateString) {
    if (expirationDateString == null) return 0;

    try {
      DateTime expirationDate = DateTime.parse(expirationDateString);
      DateTime now = DateTime.now();

      if (now.isBefore(expirationDate)) {
        return expirationDate.difference(now).inDays;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  String _getWarrantyStatus(dynamic machine) {
    if (machine?.warranty == null) return "No Warranty Info";

    String status = machine.warranty.status ?? "Unknown";
    DateTime? expirationDate = machine.warranty.expirationDate != null
        ? DateTime.parse(machine.warranty.expirationDate)
        : null;

    if (status.toLowerCase() == 'active' && expirationDate != null) {
      if (DateTime.now().isBefore(expirationDate)) {
        int daysRemaining = expirationDate.difference(DateTime.now()).inDays;
        return "$status ($daysRemaining days left)";
      } else {
        return LanguageService.get("expired");
      }
    }

    return status;
  }



  // Add this helper method to your AddTicketView class
  List<Widget> _buildAdditionalInfoSections(
    BuildContext context,
    AddTicketViewModel model,
  ) {
    List<Widget> sections = [];

    for (int i = 0; i < model.additionalInfoSections.length; i++) {
      final section = model.additionalInfoSections[i];

      sections.add(
        Container(
          margin: EdgeInsets.only(bottom: AppSizes.h20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: AppSizes.h10,
                        top: AppSizes.h10,
                      ),
                      child: Text(
                        "${LanguageService.get("additional_information")}${i + 1}",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => model.removeInfoSection(i),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.v14),
                  border: Border(
                    left: BorderSide(
                      color: AppColors.primary,
                      width: AppSizes.w4,
                    ),
                  ),
                ),
                child: TextFormField(
                  controller: section.titleController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(label: Text(
                    LanguageService.get("heading"),
                  )),
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? LanguageService.get("please_enter_heading")
                              : null,
                ),
              ),
              SizedBox(height: AppSizes.h10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.v14),
                  border: Border(
                    left: BorderSide(
                      color: AppColors.primary,
                      width: AppSizes.w4,
                    ),
                  ),
                ),
                child: TextFormField(
                  controller: section.descriptionController,
                  textInputAction: TextInputAction.next,
                  maxLines: 3,
                  decoration: InputDecoration(label: Text(
                    LanguageService.get("description"),
                  )),
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? LanguageService.get("please_enter_description")
                              : null,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return sections;
  }
}
