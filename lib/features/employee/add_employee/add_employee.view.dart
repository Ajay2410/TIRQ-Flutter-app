import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';

import '../../../core/models/hive/user/user.dart';
import '../../../core/models/machine.dart';
import '../../../core/models/organization.dart';
import '../../../core/models/relationships.dart';
import '../../../core/storage/storage.dart';
import '../../../resources/app_resources/app_resources.dart';
import 'add_employee.vm.dart';

class AddEmployeeViewAttributes {
  final String? id;
  final bool hasPasswordField;
  final bool hasReadOnly;
  AddEmployeeViewAttributes({
    required this.id,
    this.hasPasswordField = false,
    this.hasReadOnly = true,
  });
}

class AddEmployeeView extends StatelessWidget {
  const AddEmployeeView({super.key, required this.attributes});

  final AddEmployeeViewAttributes attributes;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddEmployeeViewModel>.reactive(
      viewModelBuilder: () => AddEmployeeViewModel(),
      onViewModelReady: (AddEmployeeViewModel model) => model.init(attributes),
      disposeViewModel: false,
      builder: (
          BuildContext context,
          AddEmployeeViewModel model,
          Widget? child,
          ) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildCustomAppBar(context),
          body: SafeArea(
            child:
            model.isBusy
                ? Center(child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),)
                : _buildEmployeeDetailsForm(context, model),
          ),
          bottomNavigationBar: _buildSaveButton(context, model),
        );
      },
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      surfaceTintColor: AppColors.primary,
      iconTheme: IconThemeData(color: AppColors.white),
      title: Text(
        LanguageService.get('employee_details'),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmployeeDetailsForm(
      BuildContext context,
      AddEmployeeViewModel model,
      ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w20,
        vertical: AppSizes.h10,
      ),
      child: Form(
        key: model.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, LanguageService.get('employee_details')),
            SizedBox(height: AppSizes.h10),
            _buildRearrangedEmployeeFields(context, model),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRearrangedEmployeeFields(BuildContext context, AddEmployeeViewModel model) {
    return Column(
      children: [
        // 1. Name
        attributes.hasReadOnly
            ? _buildReadOnlyTextField(
          initialValue: model.name,
          label: LanguageService.get('employee_name'),
          validator:
              (value) =>
          value?.isEmpty == true ? LanguageService.get('please_enter_name') : null,
        )
            : _buildEditableTextField(
          controller: model.nameController,
          label: LanguageService.get('employee_name'),
          validator:
              (value) =>
          value?.isEmpty == true
              ? LanguageService.get('please_enter_name')
              : null,
        ),
        SizedBox(height: AppSizes.h10),

        // 2. Role
        _buildRoleDropdown(context, model),
        SizedBox(height: AppSizes.h10),

        // 3. Country (only if not Head of Global Service)
        if(model.selectedRole.toString() != UserRole.headOfGlobalService.toString())
          _buildCountryDropdown(context, model),
        if(model.selectedRole.toString() != UserRole.headOfGlobalService.toString())
          SizedBox(height: AppSizes.h10),

        // 4. Report To
        _buildRelationshipTypeDropdown(context, model),
        SizedBox(height: AppSizes.h10),

        // 5. Phone Number
        attributes.hasReadOnly
            ? _buildReadOnlyTextField(
          initialValue: model.phoneNumber,
          label: LanguageService.get('phone_number'),
          keyboardType: TextInputType.phone,
          validator:
              (value) =>
          value?.isEmpty == true
              ? LanguageService.get('please_enter_phone_number')
              : null,
        )
            : IntlPhoneField(
          controller: model.phoneController,
          pickerDialogStyle: PickerDialogStyle(
            backgroundColor: AppColors.white,
            countryCodeStyle: TextStyle(color: AppColors.black),
            countryNameStyle: TextStyle(color: AppColors.black),
          ),
          decoration: InputDecoration(
            labelText: LanguageService.get('phone_number'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.v12),
              borderSide: BorderSide(color: AppColors.lightGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.v12),
              borderSide: BorderSide(color: AppColors.lightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.v12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: (phone) {
            model.updatePhoneNumber(phone);
          },
          initialCountryCode: 'IN',
          validator: (phone) {
            if (phone == null || phone.number.isEmpty) {
              return LanguageService.get('please_enter_phone_number');
            }
            return null;
          },
        ),
        SizedBox(height: AppSizes.h10),

        // 6. Email
        attributes.hasReadOnly
            ? _buildReadOnlyTextField(
          initialValue: model.email,
          label: LanguageService.get('email'),
          keyboardType: TextInputType.emailAddress,
          validator:
              (value) =>
          value?.isEmpty == true ? LanguageService.get('please_enter_email') : null,
        )
            : _buildEditableTextField(
          controller: model.emailController,
          label: LanguageService.get('email'),
          keyboardType: TextInputType.emailAddress,
          validator:
              (value) =>
          value?.isEmpty == true ? LanguageService.get('please_enter_email') : null,
        ),
        SizedBox(height: AppSizes.h10),
        _buildEditableTextField(
          controller: model.employeeIdController,
          label: LanguageService.get('employee_id'),
          validator:
              (value) =>
          value?.isEmpty == true ? LanguageService.get('please_enter_employee_id') : null,
        ),
        SizedBox(height: AppSizes.h10),

        // 8. Employment Type
        _buildEmploymentTypeDropdown(context, model),
        SizedBox(height: AppSizes.h10),

        _buildShiftTextField(context, model),
        SizedBox(height: AppSizes.h10),

        // 10. Joining Date
        _buildDatePickerField(
          context,
          controller: model.startDateTimeController,
          label: LanguageService.get('joining_date'),
          onTap: () => model.selectStartDateTime(context),
        ),
        SizedBox(height: AppSizes.h10),

        // 11. Factory Location
        _buildFactoryLocation(context, model),
        SizedBox(height: AppSizes.h10),

        // Machine selection for machine operators
        if(model.selectedRole.toString() == UserRole.machineOperator.toString())
          _buildManufacturerMachineSelector(context, model),

        // Custom relationship type field (shown conditionally)
        if (model.relationshipTypeController.text == 'Other')
          Padding(
            padding: EdgeInsets.only(top: AppSizes.h10),
            child: _buildEditableTextField(
              controller: model.customRelationshipTypeController,
              label: "Specify Type",
              validator:
                  (value) =>
              value?.isEmpty == true ? LanguageService.get('please_specify_type') : null,
            ),
          ),
      ],
    );
  }

  Widget _buildShiftTextField(BuildContext context, AddEmployeeViewModel model) {
    return  _buildEditableTextField(
      controller: model.shiftTimingController,
      label: LanguageService.get('shift_timing'),
      validator: null,
    );
  }

  Widget _buildEmploymentTypeDropdown(BuildContext context, AddEmployeeViewModel model) {
    return DropdownButtonFormField<String>(
      value: model.selectedEmploymentType,
      decoration: InputDecoration(
        labelText: LanguageService.get('employment_type'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide(color: AppColors.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide(color: AppColors.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      dropdownColor: AppColors.white,
      items: model.employmentTypes.map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(
            type,
            style: TextStyle(color: AppColors.black),
          ),
        );
      }).toList(),
      onChanged: (value) {
        model.updateSelectedEmploymentType(value);
      },
      validator: (value) => value == null ? LanguageService.get('please_select_employment_type') : null,
    );
  }

  Widget _buildRoleDropdown(BuildContext context, AddEmployeeViewModel model) {
    List<UserRole> roles = UserRole.values.toList();
    roles.remove(UserRole.superAdmin);
    if(getUser().organizationType == OrganizationType.manufacturer){
      roles.remove(UserRole.plantHead);
      roles.remove(UserRole.lineInCharge);
      roles.remove(UserRole.maintenanceHead);
      roles.remove(UserRole.maintenanceEngineer);
      roles.remove(UserRole.machineOperator);
      roles.remove(UserRole.labour);
    }
    else{
      roles.remove(UserRole.headOfGlobalService);
      roles.remove(UserRole.countryServiceManager);
      roles.remove(UserRole.localServiceEngineers);
      roles.remove(UserRole.installationEngineers);
    }
    return DropdownButtonFormField<UserRole>(
      value: model.selectedRole,
      decoration: InputDecoration(
        labelText: LanguageService.get('employee_role'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide(color: AppColors.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide(color: AppColors.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      dropdownColor: AppColors.white,
      items:
      roles.map((UserRole role) {
        return DropdownMenuItem<UserRole>(
          value: role,
          child: Text(
            role.displayName,
            style: TextStyle(color: AppColors.black),
          ),
        );
      }).toList(),
      onChanged: (value) {
        model.updateSelectedRole(value);
        model.relationshipTypeController.text = '';
      },
      validator:
          (value) => value == null ? LanguageService.get('please_select_role') : null,
    );
  }

  Widget _buildCountryDropdown(
      BuildContext context,
      AddEmployeeViewModel model,
      ) {
    return GestureDetector(
      onTap: () => _showSearchableCountryDropdown(context, model),
      child: AbsorbPointer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.v12),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: TextFormField(
            controller: TextEditingController(
              text:
              model.selectedCountry != null
                  ? '${model.selectedCountry!.flag} ${model.selectedCountry!.name}'
                  : '',
            ),
            decoration: InputDecoration(
              labelText: LanguageService.get('country'),
              hintText: LanguageService.get('select_country'),
              suffixIcon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.primary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.v12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.v12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.v12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            validator:
                (value) =>
            model.selectedCountry == null
                ? LanguageService.get('please_select_country')
                : null,
          ),
        ),
      ),
    );
  }

  void _showSearchableCountryDropdown(
      BuildContext context,
      AddEmployeeViewModel model,
      )
  {
    List<Country> countriesList = countries.toList();
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            List<Country> filteredCountries =
            searchQuery.isEmpty
                ? countriesList
                : countriesList
                .where(
                  (country) => country.name.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
            )
                .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSizes.v24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: AppSizes.h12),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.all(AppSizes.w20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                LanguageService.get('select_country'),
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: AppColors.gray),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.h16),

                        TextField(
                          autofocus: true,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: LanguageService.get('search_countries'),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.primary,
                            ),
                            suffixIcon:
                            searchQuery.isNotEmpty
                                ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: AppColors.gray,
                              ),
                              onPressed: () {
                                setState(() {
                                  searchQuery = '';
                                });
                              },
                            )
                                : null,
                            fillColor: AppColors.lightGray.withValues(
                              alpha: 0.3,
                            ),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSizes.v12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: AppSizes.h12,
                              horizontal: AppSizes.w16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (searchQuery.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.w20),
                      child: Row(
                        children: [
                          Text(
                            "${filteredCountries.length} ${LanguageService.get('countries_found')}",
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.gray),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: AppSizes.h8),

                  Expanded(
                    child:
                    filteredCountries.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppColors.gray.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          SizedBox(height: AppSizes.h16),
                          Text(
                            LanguageService.get('no_countries_found'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppColors.gray),
                          ),
                          Text(
                            LanguageService.get('try_another_search'),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.gray),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.w20,
                      ),
                      itemCount: filteredCountries.length,
                      itemBuilder: (context, index) {
                        final country = filteredCountries[index];
                        final isSelected =
                            model.selectedCountry == country;

                        return Container(
                          margin: EdgeInsets.only(bottom: AppSizes.h4),
                          decoration: BoxDecoration(
                            color:
                            isSelected
                                ? AppColors.primary.withValues(
                              alpha: 0.1,
                            )
                                : AppColors.transparent,
                            borderRadius: BorderRadius.circular(
                              AppSizes.v8,
                            ),
                            border:
                            isSelected
                                ? Border.all(
                              color: AppColors.primary,
                              width: 1,
                            )
                                : null,
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 32,
                              child: Text(
                                country.flag,
                                style: TextStyle(
                                  fontSize: AppSizes.v20,
                                ),
                              ),
                            ),
                            title: Text(
                              country.name,
                              style: TextStyle(
                                color:
                                isSelected
                                    ? AppColors.primary
                                    : AppColors.black,
                                fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing:
                            isSelected
                                ? Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: AppSizes.v20,
                            )
                                : null,
                            onTap: () {
                              model.updateSelectedCountry(country);
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.v8,
                              ),
                            ),
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSizes.w12,
                              vertical: AppSizes.h4,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildManufacturerMachineSelector(
      BuildContext context,
      AddEmployeeViewModel model,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<Relationship>(
          value: model.selectedManufacturer,
          decoration: const InputDecoration(
            labelText: 'Select Manufacturer',
            border: OutlineInputBorder(),
          ),
          items: model.manufacturers.map((manufacturer) {
            return DropdownMenuItem<Relationship>(
              value: manufacturer,
              child: Text(manufacturer.partnerName ?? 'Unknown Manufacturer',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

            );
          }).toList(),
          onChanged: model.onManufacturerSelected,
          isExpanded: true,
          validator: (value) => value == null ? LanguageService.get('please_select_manufacturer') : null,
        ),

        const SizedBox(height: 16),

        if (model.selectedManufacturer != null)
          DropdownButtonFormField<Machine>(
            value: model.selectedMachine,
            decoration: const InputDecoration(
              labelText: 'Select Machine',
              border: OutlineInputBorder(),
            ),
            items: model.machines.map((machine) {
              return DropdownMenuItem<Machine>(
                value: machine,
                child: Text(machine.machineName ?? 'Unknown Machine',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),),
              );
            }).toList(),
            onChanged: model.onMachineSelected,
            isExpanded: true,
            validator: (value) => value == null ? LanguageService.get('please_select_machine') : null,
          ),
      ],
    );
  }

  Widget _buildRelationshipTypeDropdown(
      BuildContext context,
      AddEmployeeViewModel model,
      ) {
    List<String> relationshipTypes = model.getRelationshipTypesForRole(
      model.selectedRole,
    );

    if (!relationshipTypes.contains('Other')) {
      relationshipTypes.add('Other');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageService.get('report_to'),
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGray),
            borderRadius: BorderRadius.circular(AppSizes.v12),
          ),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            children: [
              ...relationshipTypes.map((String type) {
                return CheckboxListTile(
                  title: Text(
                    type,
                    style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  value: model.selectedRelationshipTypes.contains(type),
                  onChanged: (bool? value) {
                    if (value == true) {
                      model.selectedRelationshipTypes.add(type);
                      if (type == 'Other') {
                        model.customRelationshipTypeController.text = '';
                      }
                    } else {
                      model.selectedRelationshipTypes.remove(type);
                    }
                    model.notifyListeners();
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                );
              }).toList(),
              if (model.selectedRelationshipTypes.contains('Other'))
                Padding(
                  padding: const EdgeInsets.only(left: 28.0, top: 8.0),
                  child: TextFormField(
                    controller: model.customRelationshipTypeController,
                    decoration: InputDecoration(
                      labelText: LanguageService.get('specify_type'),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      model.notifyListeners();
                    },
                  ),
                ),
            ],
          ),
        ),
        if (model.selectedRelationshipTypes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              LanguageService.get('please_select_relationship_type'),
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFactoryLocation(BuildContext context, AddEmployeeViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (model.isLoadingFactoryLocations)
          Container(
            padding: EdgeInsets.all(AppSizes.w16),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                SizedBox(width: AppSizes.w12),
                Text(
                  LanguageService.get('loading_factory_locations'),
                  style: TextStyle(color: AppColors.gray),
                ),
              ],
            ),
          )
        else
          DropdownButtonFormField<Units>(
            value: model.selectedFactoryLocation,
            decoration: InputDecoration(
              labelText: LanguageService.get('factory_location'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.v12),
                borderSide: BorderSide(color: AppColors.lightGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.v12),
                borderSide: BorderSide(color: AppColors.lightGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.v12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            dropdownColor: AppColors.white,
            isExpanded: true,
            items: [
              ...model.factoryLocations.map((unit) {
                return DropdownMenuItem<Units>(
                  value: unit,
                  child: Text(
                    unit.name ?? 'Unknown Location',
                    style: TextStyle(color: AppColors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              DropdownMenuItem<Units>(
                value: null,
                child: Text(
                  'Other',
                  style: TextStyle(color: AppColors.black),
                ),
              ),
            ],
            onChanged: (Units? selectedUnit) {
              if (selectedUnit == null) {
                model.updateSelectedFactoryLocation(null);
              } else {
                model.updateSelectedFactoryLocation(selectedUnit);
              }
            },
            validator: (value) {
              if (model.selectedFactoryLocation == null &&
                  model.customFactoryLocationController.text.trim().isEmpty) {
                return LanguageService.get('please_select_factory_location');
              }
              return null;
            },
          ),

        if (model.selectedFactoryLocation == null && !model.isLoadingFactoryLocations) ...[
          SizedBox(height: AppSizes.h12),
          TextFormField(
            controller: model.customFactoryLocationController,
            decoration: InputDecoration(
              labelText: LanguageService.get('specify_factory_location'),
              hintText: LanguageService.get('specify_factory_location'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.v12),
                borderSide: BorderSide(color: AppColors.lightGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.v12),
                borderSide: BorderSide(color: AppColors.lightGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.v12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (value) {
              model.updateCustomFactoryLocation(value);
            },
            validator: (value) {
              if (model.selectedFactoryLocation == null &&
                  (value == null || value.trim().isEmpty)) {
                return LanguageService.get('please_specify_factory_location');
              }
              return null;
            },
          ),
        ],

        if (model.selectedFactoryLocation != null) ...[
          SizedBox(height: AppSizes.h8),
          Container(
            padding: EdgeInsets.all(AppSizes.w12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.v8),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: AppSizes.v16,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppSizes.w8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.selectedFactoryLocation!.name ?? 'Unknown',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      if (model.selectedFactoryLocation!.locality?.isNotEmpty == true ||
                          model.selectedFactoryLocation!.country?.isNotEmpty == true)
                        Text(
                          '${model.selectedFactoryLocation!.locality ?? ''}'
                              '${model.selectedFactoryLocation!.locality?.isNotEmpty == true && model.selectedFactoryLocation!.country?.isNotEmpty == true ? ', ' : ''}'
                              '${model.selectedFactoryLocation!.country ?? ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        if (!model.isLoadingFactoryLocations && model.factoryLocations.isEmpty) ...[
          SizedBox(height: AppSizes.h8),
          Container(
            padding: EdgeInsets.all(AppSizes.w12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.v8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  size: AppSizes.v16,
                  color: Colors.orange,
                ),
                SizedBox(width: AppSizes.w8),
                Expanded(
                  child: Text(
                    LanguageService.get('no_factory_locations_found'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReadOnlyTextField({
    required String initialValue,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      readOnly: attributes.hasReadOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        fillColor: AppColors.lightGray.withValues(alpha: 0.3),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildEditableTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    bool isLastField = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction:
      isLastField ? TextInputAction.done : TextInputAction.next,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide(color: AppColors.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide(color: AppColors.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.v12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDatePickerField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.v12),
              borderSide: BorderSide(color: AppColors.lightGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.v12),
              borderSide: BorderSide(color: AppColors.lightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.v12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, AddEmployeeViewModel model) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.w20),
      child: ElevatedButton(
        onPressed: model.onSave,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, AppSizes.h50),
        ),
        child: Text(
          LanguageService.get('save'),
        ),
      ),
    );
  }
}