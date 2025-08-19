import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/core/models/hive/user/user.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/features/tickets/add_ticket/add_ticket.view.dart';
import 'package:manager/features/tickets/tickets_list/ticket_card/ticket_card.dart';
import 'package:manager/routes/routes.dart';
import 'package:manager/services/ticket.service.dart';
import 'package:manager/widgets/dialogs/resolve_request_confirmation/resolve_request_dialog.view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/models/ticket.dart';
import '../../../core/utils/type_def.dart';
import '../../../services/chat.service.dart';
import '../../../services/dialogs.service.dart';
import '../../../widgets/dialogs/loader/loader_dialog.view.dart';
import '../../../widgets/dialogs/ticket_details/ticket_details_dialog.view.dart';
import '../../Messages/chat/chat.view.dart';
import '../../../resources/app_resources/app_resources.dart';

class TicketsListViewModel extends ReactiveViewModel {
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final _ticketService = locator<TicketService>();
  final _chatService = locator<ChatService>();

  // Search query
  String _searchQuery = '';

  // Tab state
  final ReactiveValue<int> _selectedTabIndex = ReactiveValue<int>(0);
  int get selectedTabIndex => _selectedTabIndex.value;
  set selectedTabIndex(int value) {
    _selectedTabIndex.value = value;
    notifyListeners();
  }

  // Reactive values
  final ReactiveValue<List<TicketCardAttributes>> _tickets =
  ReactiveValue<List<TicketCardAttributes>>([]);
  final ReactiveValue<List<TicketCardAttributes>> _filteredTickets =
  ReactiveValue<List<TicketCardAttributes>>([]);
  final ReactiveValue<bool> _isLoading = ReactiveValue<bool>(false);

  List<TicketCardAttributes> get tickets => _filteredTickets.value;
  bool get isLoading => _isLoading.value;

  // Access to the refresh flag
  bool get isRefreshing => _ticketService.isRefreshing;

  // Getters for tab-specific tickets
  List<TicketCardAttributes> get activeTickets {
    return _filteredTickets.value.where((ticket) {
      final status = ticket.ticket.status?.toLowerCase() ?? '';
      return (status == 'inprogress' || status == 'onhold' || status == 'open');
    }).toList();
  }

  List<TicketCardAttributes> get pendingRemarkTickets {
    return _filteredTickets.value.where((ticket) {
      final status = ticket.ticket.status?.toLowerCase() ?? '';
      return status == 'pending';
    }).toList();
  }

  List<TicketCardAttributes> get resolvedTickets {
    return _filteredTickets.value.where((ticket) {
      final status = ticket.ticket.status?.toLowerCase() ?? '';
      return status == 'resolved';
    }).toList();
  }

  // Search query
  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    _searchQuery = value;
    _applyFilters();
    notifyListeners();
  }

  // StreamSubscription to listen for external refresh triggers
  StreamSubscription? _refreshSubscription;

  void init() {
    loadTickets();

    // Listen to refresh triggers from the service
    _refreshSubscription = _ticketService.refreshStream.listen((trigger) {
      if (trigger && !_ticketService.isRefreshing) {
        //  Fetching tickets from API 684408b318d422ee67af8012, 'processorId': 684408b318d422ee67af8012
        AppLogger.highlight("Received refresh trigger, refreshing tickets list");
        loadTickets();
      }
    });
  }

  Future<void> loadTickets({bool forceRefresh = false}) async {
    // Check if refresh is already in progress and not forced
    if (_ticketService.isRefreshing && !forceRefresh) {
      Fluttertoast.showToast(
        msg: 'Refresh already in progress',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    _isLoading.value = true;
    notifyListeners();

    try {
      final result = await _ticketService.getTickets(
        processorId: isProcessor ? getUser().organizationId : null,
        manufacturerId: !isProcessor ? getUser().organizationId : null,
        forceRefresh: forceRefresh,
      );

      result.fold(
            (failure) {
          // Don't show toast for "already refreshing" error if not forced
          if (failure.message != 'Refresh already in progress' || forceRefresh) {
            Fluttertoast.showToast(
              msg: 'Failed to load tickets: ${failure.message}',
            );
          }
          // Don't clear the list if it's just a refresh conflict
          if (failure.message != 'Refresh already in progress') {
            _tickets.value = [];
            _filteredTickets.value = [];
          }
        },
            (ticketList) async {
          // Convert Ticket objects to TicketCardAttributes for the UI
          List<TicketCardAttributes> ticketCards =
          ticketList.map((ticket) {
            // Calculate time elapsed
            String timeElapsed = _calculateTimeElapsed(ticket.createdAt);

            // Determine if ticket can be pinged/held based on last ping time
            bool canInteract = _canInteractWithTicket(ticket);

            // Get customer name (using machine owner or organization name)
            String customerName =
            getUser().organizationType == OrganizationType.processor
                ? ticket.manufacturerInfo?.name ?? 'Unknown Customer'
                : ticket.processorInfo?.name ?? 'Unknown Customer';

            // Get country code (placeholder - in a real app, you'd get this from customer data)
            String countryCode = _getCountryCode(customerName);

            return TicketCardAttributes(
              lastPingTime: ticket.lastPingTime,
              onPingPressed: canInteract &&
                  getUser().organizationType == OrganizationType.processor
                  ? () => pingTicket(ticket.id)
                  : canInteract
                  ? () => holdTicket(ticket.id)
                  : null,
              onChatPressed: () => navigateToChatView(ticket.id),
              id: ticket.id ?? 'Unknown',
              ticket: ticket,
              customerName: customerName,
              countryCode: countryCode,
              machineName: ticket.machine?.machineName ?? 'Unknown Machine',
              elapsedTime: timeElapsed,
              errorDescription:
              ticket.description ?? 'No error description available',
              onTicketTap: (id) => viewTicketDetails(id, ticket),
              onAddRemarkTap: (id)=>addRemark(id),
            );
          }).toList();
          _tickets.value.clear();
          notifyListeners();
          _tickets.value = ticketCards;
          _applyFilters();
        },
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load tickets: ${e.toString()}');
      _tickets.value = [];
      _filteredTickets.value = [];
    } finally {
      // In case of an error that doesn't reset the flag, we help it along
      // This can be removed if you're confident the flag is always reset
      if (_ticketService.isRefreshing) {
        _ticketService.resetRefreshFlag();
      }
    }

    _isLoading.value = false;
    notifyListeners();
  }

  // Check if ticket can be interacted with based on last ping time
  bool _canInteractWithTicket(Ticket ticket) {
    if (ticket.lastPingTime == null) return true;

    try {
      final lastPingTime = DateTime.parse(ticket.lastPingTime!);
      final now = DateTime.now().toUtc();
      return now.isAfter(lastPingTime);
    } catch (e) {
      return true;
    }
  }

  void addRemark(String ticketId) async {
    if (_ticketService.isRefreshing) {
      Fluttertoast.showToast(
        msg: 'Please wait, tickets are being refreshed',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    setBusy(true);
    notifyListeners();

    final dialogResponse  = await _dialogService.showCustomDialog<ResolveRequestResponse,ResolveRequestDialogAttributes>(
        variant: DialogType.resolveRequest,
        data: ResolveRequestDialogAttributes(
          title: 'Add Remark',
          description: '',
          cancelText: 'Cancel',
          confirmText: 'Move to Resolved',
        )
    );
    if (dialogResponse?.confirmed != true) {
      return;
    }

    final response = await _ticketService.resolveTicket(id: ticketId,closingRemark: dialogResponse!.data!.remarks);
    response.fold(
          (failure) {
        AppLogger.error(failure.message);
        Fluttertoast.showToast(
          msg: 'Failed to resolve ticket: ${failure.message}',
          backgroundColor: AppColors.error,
        );
      },
          (ticket) {
        Fluttertoast.showToast(
          msg: 'Ticket resolved successfully',
          backgroundColor: AppColors.success,
        );
        // Navigate back to the chat list and refresh
        // Navigator.of(navigatorKey.currentContext!).pop();
        // If you have a chat list view model that needs to be refreshed
        // you could use a service locator to access it and refresh it
        // final chatListViewModel = locator<ChatListViewModel>();
        // chatListViewModel.refreshChats();
        loadTickets();
      },
    );

    setBusy(false);
    loadTickets();
    notifyListeners();
  }

  // Helper method to get country code (in a real app, this would come from your data)
  String _getCountryCode(String customerName) {
    // This is just a placeholder - in a real app, you'd get the actual country code from your data
    // For demonstration, we'll return random country codes based on the first letter
    final firstLetter =
    customerName.isNotEmpty ? customerName[0].toUpperCase() : 'U';

    switch (firstLetter) {
      case 'A':
        return 'US';
      case 'B':
        return 'GB';
      case 'C':
        return 'CA';
      case 'D':
        return 'DE';
      case 'E':
        return 'ES';
      case 'F':
        return 'FR';
      case 'G':
        return 'GR';
      case 'H':
        return 'HK';
      case 'I':
        return 'IT';
      case 'J':
        return 'JP';
      case 'K':
        return 'KR';
      case 'L':
        return 'LU';
      case 'M':
        return 'MX';
      case 'N':
        return 'NL';
      case 'O':
        return 'NZ';
      case 'P':
        return 'PT';
      case 'Q':
        return 'QA';
      case 'R':
        return 'RU';
      case 'S':
        return 'SE';
      case 'T':
        return 'TR';
      case 'U':
        return 'UA';
      case 'V':
        return 'VN';
      case 'W':
        return 'WS';
      case 'X':
        return 'CN';
      case 'Y':
        return 'YE';
      case 'Z':
        return 'ZA';
      default:
        return 'US';
    }
  }

  String _calculateTimeElapsed(String? createdAt) {
    if (createdAt == null) return 'Unknown';

    try {
      final createdDate = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(createdDate);

      final totalHours = difference.inHours;
      final remainingMinutes = difference.inMinutes % 60;

      final formattedHours = totalHours.toString().padLeft(2, '0');
      final formattedMinutes = remainingMinutes.toString().padLeft(2, '0');

      return '${formattedHours}Hr : ${formattedMinutes}Min';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _applyFilters() {
    var filtered = [..._tickets.value];

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((ticket) {
        return (ticket.customerName.toLowerCase().contains(query)) ||
            (ticket.id.toLowerCase().contains(query)) ||
            (ticket.machineName.toLowerCase().contains(query)) ||
            (ticket.errorDescription.toLowerCase().contains(query));
      }).toList();
    }

    _filteredTickets.value = filtered;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  void navigateToCreateOrEditTicketView() async {
    final result = await _navigationService.navigateTo(
      Routes.addTicket,
      arguments: AddTicketViewAttributes(),
    );

    // Reload tickets if a new one was created
    loadTickets(forceRefresh: true);
  }

  bool get isProcessor =>
      getUser().organizationType == OrganizationType.processor;

  Future resolveTicket(String ticketId) async {
    if (_ticketService.isRefreshing) {
      Fluttertoast.showToast(
        msg: 'Please wait, tickets are being refreshed',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    setBusy(true);
    notifyListeners();

    final dialogResponse  = await _dialogService.showCustomDialog(
        variant: DialogType.resolveRequest,
        data: ResolveRequestDialogAttributes(
          title: 'Resolve Ticket',
          description: 'Is the issue completely resolved and do you want to close the ticket?',
          cancelText: 'Cancel',
          confirmText: 'Yes, Resolve',
        )
    );
    if (dialogResponse?.confirmed != true) {
      return;
    }

    final response = await _ticketService.resolveTicket(id: ticketId);
    response.fold(
          (failure) {
        AppLogger.error(failure.message);
        Fluttertoast.showToast(
          msg: 'Failed to resolve ticket: ${failure.message}',
          backgroundColor: AppColors.error,
        );
      },
          (ticket) {
        Fluttertoast.showToast(
          msg: 'Ticket resolved successfully',
          backgroundColor: AppColors.success,
        );
      },
    );

    setBusy(false);
    notifyListeners();
  }

  Future  requestResolveTicket(String ticketId) async {
    if (_ticketService.isRefreshing) {
      Fluttertoast.showToast(
        msg: 'Please wait, tickets are being refreshed',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    setBusy(true);
    notifyListeners();

    final response = await _ticketService.requestResolveTicket(id: ticketId);
    response.fold(
          (failure) {
        AppLogger.error(failure.message);
        Fluttertoast.showToast(
          msg: 'Failed to request resolution of ticket: ${failure.message}',
          backgroundColor: AppColors.error,
        );
      },
          (ticket) {
        Fluttertoast.showToast(
          msg: 'Request sent successfully',
          backgroundColor: AppColors.success,
        );
        // Navigate back to the chat list and refresh
        // Navigator.of(navigatorKey.currentContext!).pop();
        // If you have a chat list view model that needs to be refreshed
        // you could use a service locator to access it and refresh it
        // final chatListViewModel = locator<ChatListViewModel>();
        // chatListViewModel.refreshChats();
      },
    );

    setBusy(false);
    notifyListeners();
  }


  void viewTicketDetails(String ticketId, Ticket ticket) async {
    if (getUser().organizationType == OrganizationType.manufacturer) {
      await _dialogService.showCustomDialog(
        variant: DialogType.ticketDetails,
        data: TicketDetailsDialogAttributes(
            ticket: ticket,
            onResolvePressed: (ticketId)async  {
              // Handle resolve action
              AppLogger.info("Resolved ticket $ticketId");

              await resolveTicket(ticketId);
              loadTickets();
            },
            onHoldPressed: (ticketId, holdDuration) {
              holdTicketWithDuration(ticketId, holdDuration);
            },
            onChatPressed: (ticketId) {
              navigateToChatView(ticketId);
            },
            navigateToImageViewer: (imageUrl) {
              navigateToImageView(imageUrl);
            },
          onRequestResolvePressed: (ticketId){
              requestResolveTicket(ticketId);
          }
        ),
      );
    } else {
      if(ticket.status=='Resolved') {
        await _dialogService.showCustomDialog(
          variant: DialogType.ticketDetails,
          data: TicketDetailsDialogAttributes(
              ticket: ticket,
              onResolvePressed: (ticketId) async {
                // Handle resolve action
                AppLogger.highlight("Resolved ticket $ticketId");
                await resolveTicket(ticketId);
                loadTickets();
              },
              onHoldPressed: (ticketId, holdDuration) {
                holdTicketWithDuration(ticketId, holdDuration);
              },
              onChatPressed: (ticketId) {
                navigateToChatView(ticketId);
              },
              navigateToImageViewer: (imageUrl) {
                navigateToImageView(imageUrl);
              },
              onRequestResolvePressed: (ticketId){
                requestResolveTicket(ticketId);
              }
          ),
        );
        return;
      }
      final response = await _dialogService.showCustomDialog(
        variant: DialogType.loader,
        data: LoaderDialogAttributes(
          task: () =>
              _chatService.getChatViewAttributesForTicket(ticketId: ticketId),
          message: "Loading chat...",
        ),
      );
      if (response?.data != null) {
        (response!.data as EitherResult<ChatViewAttributes>).fold(
              (failure) {
            AppLogger.error(failure.message);
            Fluttertoast.showToast(msg: failure.message);
          },
              (attributes) {
            _navigationService.navigateTo(Routes.chat, arguments: attributes);
          },
        );
      }
    }
    loadTickets();
  }
  void navigateToChatView(String ticketId) async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.loader,
      data: LoaderDialogAttributes(
        task: () =>
            _chatService.getChatViewAttributesForTicket(ticketId: ticketId),
        message: "Loading chat...",
      ),
    );
    if (response?.data != null) {
      (response!.data as EitherResult<ChatViewAttributes>).fold(
            (failure) {
          AppLogger.error(failure.message);
          Fluttertoast.showToast(msg: failure.message);
        },
            (attributes) {
                _navigationService.navigateTo(
                    Routes.chat, arguments: attributes);
        },
      );
    }
  }

  void navigateToImageView(String imageUrl) async {
    _navigationService.navigateTo(Routes.imageViewerView, arguments: imageUrl);
  }

  void holdTicketWithDuration(String ticketId, String holdDuration) async {
    if (_ticketService.isRefreshing) {
      Fluttertoast.showToast(
        msg: 'Please wait, tickets are being refreshed',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    final response = await _ticketService.holdTicket(
        id: ticketId, nextPingTime: holdDuration);
    response.fold(
          (failure) {
        AppLogger.error(failure.message);
        Fluttertoast.showToast(
            msg: 'Failed to Reschedule ticket: ${failure.message}');
      },
          (ticket) {
        loadTickets(forceRefresh: true);
        Fluttertoast.showToast(
          msg: 'Ticket Reschedule for $holdDuration',
          backgroundColor: AppColors.warning,
        );
      },
    );
  }

  // Helper method to format duration
  String _formatDuration(Duration duration) {
    if (duration.inHours >= 24) {
      return '${duration.inDays} day${duration.inDays != 1 ? 's' : ''}';
    } else {
      return '${duration.inHours} hour${duration.inHours != 1 ? 's' : ''}';
    }
  }

  void holdTicket(String ticketId) async {
    if (_ticketService.isRefreshing) {
      Fluttertoast.showToast(
        msg: 'Please wait, tickets are being refreshed',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    final response = await _ticketService.holdTicket(
      id: ticketId,
      // If no specific time is provided, default to 1 hour from now
      nextPingTime: '1 Hour',
    );
    response.fold(
          (failure) {
        AppLogger.error(failure.message);
        Fluttertoast.showToast(
            msg: 'Failed to hold ticket: ${failure.message}');
      },
          (ticket) {
        loadTickets(forceRefresh: true);
        Fluttertoast.showToast(
          msg: 'Ticket temporarily held',
          backgroundColor: AppColors.warning,
        );
      },
    );
  }

  void pingTicket(String ticketId) async {
    if (_ticketService.isRefreshing) {
      Fluttertoast.showToast(
        msg: 'Please wait, tickets are being refreshed',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    final response = await _ticketService.pingTicket(id: ticketId);
    response.fold(
          (failure) {
        AppLogger.error(failure.message);
        Fluttertoast.showToast(msg: 'Failed to ping : ${failure.message}');
      },
          (ticket) {
        loadTickets(forceRefresh: true);
        Fluttertoast.showToast(
          msg: 'Ticket pinged successfully',
          backgroundColor: AppColors.success,
        );
      },
    );
  }

  @override
  void dispose() {
    // Clean up the subscription when the view model is disposed
    _refreshSubscription?.cancel();
    super.dispose();
  }
}