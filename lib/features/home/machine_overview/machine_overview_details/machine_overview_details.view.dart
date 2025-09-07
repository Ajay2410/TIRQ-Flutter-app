import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:shimmer/shimmer.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common_text_field.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:manager/core/locator.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/features/home/machine_overview/machine_overview_details/machine_overview_details.vm.dart';
import 'package:manager/core/models/machine_overview_model.dart';
import 'package:manager/services/dialogs.service.dart';
import 'package:manager/widgets/dialogs/create_ticket/create_ticket_dialog.view.dart';

class MachineOverviewDetailsView extends StatefulWidget {
  final MachineOverviewList? machine;

  const MachineOverviewDetailsView({super.key, this.machine});

  @override
  State<MachineOverviewDetailsView> createState() => _MachineOverviewDetailsViewState();
}

class _MachineOverviewDetailsViewState extends State<MachineOverviewDetailsView> {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  late TextEditingController _remarkController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _remarkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MachineOverviewDetailsViewModel>.reactive(
      viewModelBuilder: () => MachineOverviewDetailsViewModel()..init(widget.machine?.machineId ?? ''),
      builder: (context, viewModel, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              // Return the changes flag from the view model
              Navigator.of(context).pop(viewModel.hasChanges);
            }
          },
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, viewModel),
                  Expanded(
                    child: Container(
                      color: AppColors.white,
                      child:
                          viewModel.isLoading
                              ? _buildLoadingState()
                              : viewModel.hasError
                              ? _buildErrorState(viewModel)
                              : SingleChildScrollView(padding: const EdgeInsets.all(16), child: _buildMachineDetails(viewModel)),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: _buildFloatingActionButton(),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return Builder(
      builder:
          (context) => FloatingActionButton.extended(
            onPressed: () async {
              // await _dialogService.showCustomDialog(
              //   variant: DialogType.createTicket,
              //   data: CreateTicketDialogAttributes(
              //     onSubmit: (problem, errorCode, additionalNotes, attachments) {
              //       // Handle ticket submission
              //       print('Problem: $problem');
              //       print('Error Code: $errorCode');
              //       print('Additional Notes: $additionalNotes');
              //       print('Attachments: ${attachments.length} files');
              //       // TODO: Implement actual ticket creation logic
              //     },
              //     onCancel: () {
              //       print('Ticket creation cancelled');
              //     },
              //   ),
              // );
            },
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            icon: const Icon(Icons.add, size: 20),
            label: Text('create_ticket'.lang, style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
    );
  }

  Widget _buildAppBar(BuildContext context, MachineOverviewDetailsViewModel viewModel) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white),
        onPressed: () {
          if (mounted) {
            _navigationService.back();
          }
        },
      ),
      titleSpacing: 0,
      title: Text(
        "#${widget.machine?.modelNumber ?? ""} - ${viewModel.machineDetails?.machineName ?? widget.machine?.machineName ?? "Unknown "
                "Machine"}",
        style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: _buildShimmerContent());
  }

  Widget _buildShimmerContent() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Machine name field shimmer
          _buildShimmerTextField(),
          const SizedBox(height: 16),

          // Model number field shimmer
          _buildShimmerTextField(),
          const SizedBox(height: 16),

          // Machine type field shimmer
          _buildShimmerTextField(),
          const SizedBox(height: 16),

          // Remarks field shimmer
          _buildShimmerTextField(),
          const SizedBox(height: 24),

          // Processing dimensions section shimmer
          _buildShimmerSectionTitle(),
          const SizedBox(height: 16),

          // Processing dimensions content shimmer
          _buildShimmerProcessingDimensions(),
          const SizedBox(height: 24),

          // Notes field shimmer
          _buildShimmerTextField(maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildShimmerTextField({int maxLines = 1}) {
    return Container(height: maxLines == 1 ? 60 : 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)));
  }

  Widget _buildShimmerSectionTitle() {
    return Container(height: 20, width: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)));
  }

  Widget _buildShimmerProcessingDimensions() {
    return Column(
      children: [
        // Maximum processing size
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 10),
                  Row(children: [Expanded(child: _buildShimmerInfoRow()), const SizedBox(width: 14), Expanded(child: _buildShimmerInfoRow())]),
                ],
              ),
            ),
            Container(height: 56, color: AppColors.lightGray, width: 1),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 10),
                  Row(children: [Expanded(child: _buildShimmerInfoRow()), const SizedBox(width: 14), Expanded(child: _buildShimmerInfoRow())]),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(height: 1, color: AppColors.lightGray),
        const SizedBox(height: 20),

        // Thickness and max speed row
        Row(children: [Expanded(child: _buildShimmerInfoRow()), const SizedBox(width: 14), Expanded(child: _buildShimmerInfoRow())]),
        const SizedBox(height: 20),
        Container(height: 1, color: AppColors.lightGray),
        const SizedBox(height: 20),

        // Total power
        _buildShimmerInfoRow(),
      ],
    );
  }

  Widget _buildShimmerInfoRow() {
    return Row(
      children: [
        Container(width: 33, height: 33, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 12, width: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 4),
              Container(height: 14, width: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(MachineOverviewDetailsViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.textGray),
          const SizedBox(height: 16),
          Text(
            viewModel.errorMessage,
            style: TextStyle(color: AppColors.textGray, fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: viewModel.refreshMachineDetails, child: Text('retry'.lang)),
        ],
      ),
    );
  }

  Widget _buildMachineDetails(MachineOverviewDetailsViewModel viewModel) {
    final machineData = viewModel.machineDetails;
    if (machineData == null) return const SizedBox.shrink();

    // Initialize controllers with actual data
    _remarkController.text = machineData.remarks ?? '';
    _notesController.text = machineData.notes ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonTextField(
          controller: TextEditingController(text: machineData.machineName ?? 'Unknown Machine'),
          label: 'machine_model_name'.lang,
          placeholder: '',
          readOnly: true,
          enabled: false,
          disabledBackgroundColor: const Color(0xFFF8FBFE),
        ),
        const SizedBox(height: 16),

        CommonTextField(
          controller: TextEditingController(text: machineData.modelNumber ?? 'N/A'),
          label: 'model_number'.lang,
          placeholder: '',
          readOnly: true,
          enabled: false,
          disabledBackgroundColor: const Color(0xFFF8FBFE),
        ),
        const SizedBox(height: 16),

        CommonTextField(
          controller: TextEditingController(text: machineData.machineType ?? 'N/A'),
          label: 'functionality'.lang,
          placeholder: '',
          readOnly: true,
          enabled: false,
          disabledBackgroundColor: const Color(0xFFF8FBFE),
        ),
        const SizedBox(height: 16),

        CommonTextField(
          controller: _remarkController,
          label: 'remark'.lang,
          placeholder: 'enter_remark_here'.lang,
          maxLines: 1,
          suffixIcon: CustomPopup(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add machine add-ons like:', style: TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                SizedBox(height: 4),
                Text(
                  '''• Machine with 2/4 station loader\n• Machine with loader & unloader\n• Machine with Auto detection\n• Machine with Single/double blower (furnace/washing)\netc.''',
                  style: TextStyle(color: AppColors.white, fontSize: 9, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            position: PopupPosition.top,
            arrowColor: AppColors.textGray,
            backgroundColor: AppColors.textGray,
            child: Padding(padding: EdgeInsets.all(16), child: Image.asset(AppImages.alert, width: 16, height: 16)),
          ),
        ),
        const SizedBox(height: 24),

        _buildSectionTitle('processing_dimensions'.lang),
        const SizedBox(height: 16),

        if (viewModel.hasProcessingDimensions) ...[
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('maximum_processing_size'.lang, style: TextStyle(color: AppColors.textGray, fontSize: 12, fontWeight: FontWeight.w500)),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoRow(
                                AppImages.height,
                                'height'.lang,
                                '${machineData.processingDimensions?.maxHeight ?? "-"}',
                                AppColors.color41C293,
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: _buildInfoRow(
                                AppImages.width,
                                'width'.lang,
                                '${machineData.processingDimensions?.maxWidth ?? "-"}',
                                AppColors.primarySuperLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(height: 56, color: AppColors.lightGray, width: 1),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('minimum_processing_size'.lang, style: TextStyle(color: AppColors.textGray, fontSize: 12, fontWeight: FontWeight.w500)),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoRow(
                                AppImages.height,
                                'height'.lang,
                                '${machineData.processingDimensions?.minHeight ?? "-"}',
                                AppColors.color41C293,
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: _buildInfoRow(
                                AppImages.width,
                                'width'.lang,
                                '${machineData.processingDimensions?.minWidth ?? "-"}',
                                AppColors.primarySuperLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: AppColors.lightGray),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildInfoRow(AppImages.thickness, 'thickness'.lang, machineData.processingDimensions?.thickness ?? "-", AppColors.lightCoral),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _buildInfoRow(
                  AppImages.maxSpeed,
                  'max_speed'.lang,
                  '${machineData.processingDimensions?.maxSpeed ?? "-"}',
                  AppColors.blueLagoon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.lightGray),
          const SizedBox(height: 20),

          _buildInfoRow(AppImages.powerConsumption, "${'total_power'.lang} (kW)", '${machineData.totalPower ?? "-"}', AppColors.primarySuperLight),
        ] else ...[
          Text('No processing dimensions available', style: TextStyle(color: AppColors.textGray, fontSize: 14, fontStyle: FontStyle.italic)),
        ],
        const SizedBox(height: 24),

        CommonTextField(controller: _notesController, label: 'notes_special_instructions'.lang, placeholder: 'link_here'.lang, maxLines: 3),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(text, style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _buildInfoRow(String iconPath, String label, String value, Color iconColor, {bool isWarning = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
          child: Image.asset(iconPath, width: 17, height: 17, color: iconColor),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(color: isWarning ? AppColors.redBack : AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
