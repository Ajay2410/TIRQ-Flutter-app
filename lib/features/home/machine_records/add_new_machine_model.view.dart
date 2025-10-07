import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/packages/animated_custom_dropdown/custom_dropdown.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/services/machine.service.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/widgets/common_text_field.dart';

class AddNewMachineModelView extends StatefulWidget {
  final Map<String, dynamic>? machine;

  const AddNewMachineModelView({super.key, this.machine});

  @override
  State<AddNewMachineModelView> createState() => _AddNewMachineModelViewState();
}

class _AddNewMachineModelViewState extends State<AddNewMachineModelView> {
  final _formKey = GlobalKey<FormState>();
  final _machineService = locator<MachineService>();
  bool _isLoading = false;

  final TextEditingController _machineNameController = TextEditingController();
  final TextEditingController _modelNumberController = TextEditingController();
  final TextEditingController _functionalityController =
      TextEditingController();
  final TextEditingController _maxHeightController = TextEditingController();
  final TextEditingController _maxWidthController = TextEditingController();
  final TextEditingController _minHeightController = TextEditingController();
  final TextEditingController _minWidthController = TextEditingController();
  final TextEditingController _thicknessController = TextEditingController();
  final TextEditingController _maxSpeedController = TextEditingController();
  final TextEditingController _totalPowerController = TextEditingController();
  final TextEditingController _operatingManualsController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _addOnController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();

  String? _selectedFunctionality;

  final List<String> _functionalityOptions = [
    'Fully Automatic',
    'Semi Automatic',
    'Manual',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.machine != null) {
      _populateFormWithMachineData();
    }
  }

  void _populateFormWithMachineData() {
    final machine = widget.machine!;
    _machineNameController.text =
        (machine['machine_name'] ?? '').toString().toUpperCase();
    _modelNumberController.text =
        (machine['model_number'] ?? '').toString().toUpperCase();
    _serialNumberController.text = machine['serial_number'] ?? '';
    _selectedFunctionality = machine['functionality'] ?? '';
    _functionalityController.text = machine['functionality'] ?? '';
    _maxHeightController.text = machine['max_height'] ?? '';
    _maxWidthController.text = machine['max_width'] ?? '';
    _minHeightController.text = machine['min_height'] ?? '';
    _minWidthController.text = machine['min_width'] ?? '';
    _thicknessController.text = machine['thickness'] ?? '';
    _maxSpeedController.text = machine['max_speed'] ?? '';
    _totalPowerController.text = machine['total_power'] ?? '';
    _operatingManualsController.text = machine['operating_manuals'] ?? '';
    _notesController.text = machine['notes'] ?? '';
    _addOnController.text = machine['remarks'] ?? '';
  }

  @override
  void dispose() {
    _machineNameController.dispose();
    _modelNumberController.dispose();
    _serialNumberController.dispose();
    _functionalityController.dispose();
    _maxHeightController.dispose();
    _maxWidthController.dispose();
    _minHeightController.dispose();
    _minWidthController.dispose();
    _thicknessController.dispose();
    _maxSpeedController.dispose();
    _totalPowerController.dispose();
    _operatingManualsController.dispose();
    _notesController.dispose();
    _addOnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppColors.scaffoldBackground,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGeneralInfoSection(),
                      const SizedBox(height: 24),
                      _buildProcessingDimensionsSection(),
                      const SizedBox(height: 24),
                      _buildPowerSection(),
                      const SizedBox(height: 24),
                      _buildDocumentationSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -5),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: _buildSaveButton(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
        icon: Image.asset(
          AppImages.back,
          width: 24,
          height: 24,
          color: AppColors.white,
        ),
        onPressed: () {
          if (mounted) {
            Get.back();
          }
        },
      ),
      titleSpacing: 0,
      title: Text(
        widget.machine != null
            ? 'edit_machine_model'.lang
            : 'add_new_machine_model'.lang,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGeneralInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CommonTextField(
        //   controller: _serialNumberController,
        //   label: 'serial_number'.lang,
        //   placeholder: 'SN-12345',
        //   validator: (value) {
        //     if (value == null || value.trim().isEmpty) {
        //       return '${'serial_number'.lang} ${'required'.lang}';
        //     }
        //     return null;
        //   },
        // ),
        // const SizedBox(height: 16),
        CommonTextField(
          controller: _machineNameController,
          label: 'machine_model_name'.lang,
          placeholder: 'enter_machine_name'.lang,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '${'machine_model_name'.lang} ${'required'.lang}';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CommonTextField(
          controller: _modelNumberController,
          label: 'model_number'.lang,
          placeholder: 'enter_model_number'.lang,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '${'model_number'.lang} ${'required'.lang}';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildDropdownField(),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'functionality'.lang,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        FormField<String>(
          validator: (value) {
            if (_selectedFunctionality == null ||
                _selectedFunctionality!.isEmpty) {
              return '${'functionality'.lang} ${'required'.lang}';
            }
            return null;
          },
          builder: (FormFieldState<String> field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDropdown(
                  items: _functionalityOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedFunctionality = value;
                      _functionalityController.text = value;
                    });
                    field.didChange(value);
                    if (value.isNotEmpty) {
                      field.reset();
                      field.validate();
                    }
                  },
                  controller: TextEditingController(
                    text: _selectedFunctionality,
                  ),
                  hintText: 'select_functionality'.lang,
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  selectedStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  listItemStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  fillColor: AppColors.white,
                  borderSide: BorderSide(
                    color:
                        field.hasError ? AppColors.error : AppColors.lightGrey,
                    width: field.hasError ? 2.0 : 1.0,
                  ),
                  errorBorderSide: BorderSide(color: AppColors.error, width: 1),
                  fieldSuffixIcon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      field.errorText!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildProcessingDimensionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'processing_dimensions'.lang,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'maximum_processing_size'.lang,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CommonTextField(
                controller: _maxHeightController,
                label: 'height'.lang,
                placeholder: 'MM',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '${'height'.lang} ${'required'.lang}';
                  }
                  if (double.tryParse(value) == null) {
                    return '${'height'.lang} ${'invalid_number'.lang}';
                  }
                  return null;
                },
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    AppImages.height,
                    width: 20,
                    height: 20,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CommonTextField(
                controller: _maxWidthController,
                label: 'width'.lang,
                placeholder: 'MM',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '${'width'.lang} ${'required'.lang}';
                  }
                  if (double.tryParse(value) == null) {
                    return '${'width'.lang} ${'invalid_number'.lang}';
                  }
                  return null;
                },
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    AppImages.width,
                    width: 20,
                    height: 20,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'minimum_processing_size'.lang,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CommonTextField(
                controller: _minHeightController,
                label: 'height'.lang,
                placeholder: 'MM',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '${'height'.lang} ${'required'.lang}';
                  }
                  if (double.tryParse(value) == null) {
                    return '${'height'.lang} ${'invalid_number'.lang}';
                  }
                  return null;
                },
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    AppImages.height,
                    width: 20,
                    height: 20,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CommonTextField(
                controller: _minWidthController,
                label: 'width'.lang,
                placeholder: 'MM',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '${'width'.lang} ${'required'.lang}';
                  }
                  if (double.tryParse(value) == null) {
                    return '${'width'.lang} ${'invalid_number'.lang}';
                  }
                  return null;
                },
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    AppImages.width,
                    width: 20,
                    height: 20,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CommonTextField(
          controller: _thicknessController,
          label: 'thickness'.lang,
          placeholder: 'enter_thickness_processing_range'.lang,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '${'thickness'.lang} ${'required'.lang}';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CommonTextField(
          controller: _maxSpeedController,
          label: 'max_speed'.lang,
          placeholder: 'enter_max_processing_speed'.lang,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '${'max_speed'.lang} ${'required'.lang}';
            }
            if (double.tryParse(value) == null) {
              return '${'max_speed'.lang} ${'invalid_number'.lang}';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPowerSection() {
    return CommonTextField(
      controller: _totalPowerController,
      label: 'total_power'.lang,
      placeholder: 'enter_max_power_of_machine'.lang,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '${'total_power'.lang} ${'required'.lang}';
        }
        if (double.tryParse(value) == null) {
          return '${'total_power'.lang} ${'invalid_number'.lang}';
        }
        return null;
      },
      prefixIcon: Padding(
        padding: const EdgeInsets.all(16),
        child: Image.asset(
          AppImages.powerConsumption,
          width: 20,
          height: 20,
          color: AppColors.textGrey,
        ),
      ),
    );
  }

  Widget _buildDocumentationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonTextField(
          controller: _addOnController,
          label: 'add_on'.lang,
          placeholder: 'enter_add_on_here'.lang,
          maxLines: 1,
        ),
        const SizedBox(height: 16),

        CommonTextField(
          controller: _operatingManualsController,
          label: 'operating_manuals'.lang,
          placeholder: 'enter_link_URL'.lang,
        ),
        const SizedBox(height: 16),
        CommonTextField(
          controller: _notesController,
          label: 'notes_special_instructions'.lang,
          placeholder: 'enter_notes_or_special_instruction'.lang,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            _isLoading
                ? null
                : () {
                  if (_formKey.currentState!.validate()) {
                    _saveMachineToRecord();
                  }
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(45),
          ),
          elevation: 0,
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  widget.machine != null
                      ? 'update_machine'.lang
                      : 'save_machine_to_record'.lang,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  void _saveMachineToRecord() async {
    if (_isLoading) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final isEditMode = widget.machine != null;
      final machineId = widget.machine?['id'];

      if (isEditMode && machineId == null) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Invalid machine ID for update',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16,
          );
        }
        return;
      }

      final processingDimensions = {
        'maxHeight': int.tryParse(_maxHeightController.text) ?? 0,
        'maxWidth': int.tryParse(_maxWidthController.text) ?? 0,
        'minHeight': int.tryParse(_minHeightController.text) ?? 0,
        'minWidth': int.tryParse(_minWidthController.text) ?? 0,
        'thickness': _thicknessController.text.trim(),
        'maxSpeed': int.tryParse(_maxSpeedController.text) ?? 0,
      };

      if (isEditMode) {
        final updateData = {
          'machineName': _machineNameController.text.trim(),
          'modelNumber': _modelNumberController.text.trim(),
          'serialNumber': _serialNumberController.text.trim(),
          'machine_type': _selectedFunctionality ?? 'Fully Automatic',
          'processingDimensions': processingDimensions,
          'totalPower': int.tryParse(_totalPowerController.text) ?? 0,
          'manualsLink': _operatingManualsController.text.trim(),
          'notes': _notesController.text.trim(),
          'status': 'Available',
          'remarks': _addOnController.text.trim(),
        };

        final result = await _machineService.updateMachineRecord(
          machineId: machineId!,
          updateData: updateData,
        );

        result.fold(
          (failure) {
            if (mounted) {
              Fluttertoast.showToast(
                msg: failure.message,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16,
              );
            }
          },
          (updatedMachineData) {
            if (mounted) {
              Fluttertoast.showToast(
                msg: 'Machine updated successfully!',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: AppColors.success,
                textColor: Colors.white,
                fontSize: 16,
              );
            }

            Get.back(result: updatedMachineData);
          },
        );
      } else {
        final result = await _machineService.createMachineNew(
          machineName: _machineNameController.text.trim(),
          modelNumber: _modelNumberController.text.trim(),
          serialNumber: _serialNumberController.text.trim(),
          machineType: _selectedFunctionality ?? 'Fully Automatic',
          processingDimensions: processingDimensions,
          totalPower: int.tryParse(_totalPowerController.text) ?? 0,
          manualsLink: _operatingManualsController.text.trim(),
          notes: _notesController.text.trim(),
          remarks: _addOnController.text.trim(),
          status: 'Available',
        );

        result.fold(
          (failure) {
            if (mounted) {
              Fluttertoast.showToast(
                msg: failure.message,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16,
              );
            }
          },
          (machine) {
            if (mounted) {
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

            Get.back(result: machine);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'An unexpected error occurred',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
