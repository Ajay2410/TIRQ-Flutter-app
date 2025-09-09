import 'package:flutter/material.dart';
import 'package:manager/features/home/organization_home/organization_home.view.dart';
import 'package:manager/features/profile/home/profile.view.dart';
import 'package:manager/features/stage/stage.view.dart';
import 'package:manager/features/tickets/tickets_list/tickets_list.view.dart';
import 'package:manager/services/dialogs.service.dart';
import 'package:manager/services/stage.service.dart';
import 'package:manager/widgets/dialogs/confirmation/confirmation_dialog.view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../core/locator.dart';
import '../../services/ticket.service.dart';
import '../Messages/chat_list/chat_list.view.dart';
import '../contacts/chat_list/contacts_list.view.dart';

class StageViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _stageService = locator<StageService>();
  final _dialogService =
      locator<DialogService>(); // Add this if you're using DialogService
  final _ticketService = locator<TicketService>();

  bool get isCloseTicketDialogOpen =>
      _stageService.isCloseTicketDialogOpen.value;
  String get requestedTicketId => _stageService.requestedTicketId.value ?? '';

  int get selectedBottomNavIndex => _stageService.selectedBottomNavIndex.value;

  List<Widget> get bottomNavItems => [
    OrganizationHomeView(),
    TicketsListView(),
    ChatListView(),
    ContactsListView(),
    ProfileView(),
  ];

  void init(StageViewAttributes attributes) {
    updateSelectedBottomNavIndex(attributes.selectedBottomNavIndex);
  }

  updateSelectedBottomNavIndex(int index) {
    _stageService.updateSelectedBottomNavIndex(index);
  }

  void navigateToRoute(String route) async {
    await _navigationService.navigateTo(route);
  }

  resolveTicket(String ticketId) async {
    await _ticketService.resolveTicket(id: ticketId);
    closeDialog();
  }

  rejectTicket(String ticketId) async {
    await _ticketService.rejectResolveTicket(id: ticketId);
    closeDialog();
  }

  closeDialog() {
    _stageService.setCloseTicketDialogOpen(false, null);
  }

  // New method to handle back button press
  Future<bool> handleBackPress(BuildContext context) async {
    // If you're using stacked_services DialogService
    final dialogResponse = await _dialogService.showCustomDialog(
      variant: DialogType.confirmation,
      data: ConfirmationDialogAttributes(
        title: 'Exit App',
        description: 'Are you sure you want to exit the app?',
        confirmText: 'Yes',
        cancelText: 'No',
      ),
    );

    return dialogResponse?.confirmed ?? false;
  }

  @override
  List<ListenableServiceMixin> get listenableServices => [_stageService];
}
