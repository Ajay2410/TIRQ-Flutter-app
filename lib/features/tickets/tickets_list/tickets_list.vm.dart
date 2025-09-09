import 'package:manager/features/tickets/add_ticket/add_ticket.view.dart';
import 'package:manager/routes/routes.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/models/ticket_model.dart';
import '../../../services/ticket.service.dart';
import '../../../services/stage.service.dart';

class TicketsListViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _ticketService = locator<TicketService>();
  final _stageService = locator<StageService>();

  // Search query
  String _searchQuery = '';

  // Tab state
  final ReactiveValue<int> _selectedTabIndex = ReactiveValue<int>(0);
  int get selectedTabIndex => _selectedTabIndex.value;
  set selectedTabIndex(int value) {
    _selectedTabIndex.value = value;
    _loadTicketsForCurrentTab();
    notifyListeners();
  }

  // Pagination state
  final ReactiveValue<int> _activePage = ReactiveValue<int>(1);
  final ReactiveValue<int> _resolvedPage = ReactiveValue<int>(1);
  final ReactiveValue<bool> _hasMoreActive = ReactiveValue<bool>(true);
  final ReactiveValue<bool> _hasMoreResolved = ReactiveValue<bool>(true);
  final ReactiveValue<bool> _isLoadingMore = ReactiveValue<bool>(false);

  int get activePage => _activePage.value;
  int get resolvedPage => _resolvedPage.value;
  bool get hasMoreActive => _hasMoreActive.value;
  bool get hasMoreResolved => _hasMoreResolved.value;
  bool get isLoadingMore => _isLoadingMore.value;

  // Reactive values
  final ReactiveValue<List<TicketModel>> _activeTickets =
      ReactiveValue<List<TicketModel>>([]);
  final ReactiveValue<List<TicketModel>> _resolvedTickets =
      ReactiveValue<List<TicketModel>>([]);
  final ReactiveValue<bool> _isLoading = ReactiveValue<bool>(false);

  List<TicketModel> get activeTickets => _activeTickets.value;
  List<TicketModel> get resolvedTickets => _resolvedTickets.value;
  bool get isLoading => _isLoading.value;

  // Search query
  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    _searchQuery = value;
    _applySearchFilters();
    notifyListeners();
  }

  void init() {
    _loadTicketsForCurrentTab();
  }

  Future<void> _loadTicketsForCurrentTab({bool forceRefresh = false}) async {
    if (forceRefresh) {
      // Reset pagination when force refreshing
      _activePage.value = 1;
      _resolvedPage.value = 1;
      _hasMoreActive.value = true;
      _hasMoreResolved.value = true;
      _activeTickets.value = [];
      _resolvedTickets.value = [];
    }

    if (selectedTabIndex == 0) {
      await _loadActiveTickets();
    } else {
      await _loadResolvedTickets();
    }
  }

  Future<void> _loadActiveTickets() async {
    if (_isLoading.value) return;

    _isLoading.value = true;
    notifyListeners();

    try {
      // Load tickets with status "Active" and "In Progress"
      final activeResult = await _ticketService.getTicketsByStatus(
        status: 'Active',
        page: _activePage.value,
        limit: 5,
        forceRefresh: _activePage.value == 1,
      );

      final inProgressResult = await _ticketService.getTicketsByStatus(
        status: 'In Progress',
        page: _activePage.value,
        limit: 5,
        forceRefresh: _activePage.value == 1,
      );

      List<TicketModel> combinedTickets = [];

      activeResult.fold(
        (failure) {
          print('Error loading active tickets: ${failure.message}');
        },
        (paginatedResponse) {
          combinedTickets.addAll(paginatedResponse.data);
        },
      );

      inProgressResult.fold(
        (failure) {
          print('Error loading in progress tickets: ${failure.message}');
        },
        (paginatedResponse) {
          combinedTickets.addAll(paginatedResponse.data);
        },
      );

      if (_activePage.value == 1) {
        _activeTickets.value = combinedTickets;
      } else {
        _activeTickets.value = [..._activeTickets.value, ...combinedTickets];
      }

      // Check if we have more tickets from either status
      bool hasMoreActive = false;
      bool hasMoreInProgress = false;

      activeResult.fold((failure) {}, (paginatedResponse) {
        hasMoreActive = _activePage.value < paginatedResponse.pages;
      });

      inProgressResult.fold((failure) {}, (paginatedResponse) {
        hasMoreInProgress = _activePage.value < paginatedResponse.pages;
      });

      _hasMoreActive.value = hasMoreActive || hasMoreInProgress;
    } catch (e) {
      print('Exception loading active tickets: $e');
      if (_activePage.value == 1) {
        _activeTickets.value = [];
      }
    }

    _isLoading.value = false;
    notifyListeners();
  }

  Future<void> _loadResolvedTickets() async {
    if (_isLoading.value) return;

    _isLoading.value = true;
    notifyListeners();

    try {
      // Load tickets with status "Resolved" and "Rejected"
      final resolvedResult = await _ticketService.getTicketsByStatus(
        status: 'Resolved',
        page: _resolvedPage.value,
        limit: 5,
        forceRefresh: _resolvedPage.value == 1,
      );

      final rejectedResult = await _ticketService.getTicketsByStatus(
        status: 'Rejected',
        page: _resolvedPage.value,
        limit: 5,
        forceRefresh: _resolvedPage.value == 1,
      );

      List<TicketModel> combinedTickets = [];

      resolvedResult.fold(
        (failure) {
          print('Error loading resolved tickets: ${failure.message}');
        },
        (paginatedResponse) {
          combinedTickets.addAll(paginatedResponse.data);
        },
      );

      rejectedResult.fold(
        (failure) {
          print('Error loading rejected tickets: ${failure.message}');
        },
        (paginatedResponse) {
          combinedTickets.addAll(paginatedResponse.data);
        },
      );

      if (_resolvedPage.value == 1) {
        _resolvedTickets.value = combinedTickets;
      } else {
        _resolvedTickets.value = [
          ..._resolvedTickets.value,
          ...combinedTickets,
        ];
      }

      // Check if we have more tickets from either status
      bool hasMoreResolved = false;
      bool hasMoreRejected = false;

      resolvedResult.fold((failure) {}, (paginatedResponse) {
        hasMoreResolved = _resolvedPage.value < paginatedResponse.pages;
      });

      rejectedResult.fold((failure) {}, (paginatedResponse) {
        hasMoreRejected = _resolvedPage.value < paginatedResponse.pages;
      });

      _hasMoreResolved.value = hasMoreResolved || hasMoreRejected;
    } catch (e) {
      print('Exception loading resolved tickets: $e');
      if (_resolvedPage.value == 1) {
        _resolvedTickets.value = [];
      }
    }

    _isLoading.value = false;
    notifyListeners();
  }

  Future<void> loadMoreTickets() async {
    if (_isLoadingMore.value || !hasMoreTickets) return;

    _isLoadingMore.value = true;
    notifyListeners();

    try {
      if (selectedTabIndex == 0) {
        _activePage.value++;
        await _loadActiveTickets();
      } else {
        _resolvedPage.value++;
        await _loadResolvedTickets();
      }
    } finally {
      _isLoadingMore.value = false;
      notifyListeners();
    }
  }

  Future<void> loadTickets({bool forceRefresh = false}) async {
    await _loadTicketsForCurrentTab(forceRefresh: forceRefresh);
  }

  void _applySearchFilters() {
    // For now, we'll apply search filters on the client side
    // In a real app, you might want to implement server-side search
    // This is a placeholder for search functionality
  }

  void resetFilters() {
    _searchQuery = '';
    _applySearchFilters();
    notifyListeners();
  }

  void navigateToCreateOrEditTicketView() async {
    await _navigationService.navigateTo(
      Routes.addTicket,
      arguments: AddTicketViewAttributes(),
    );
  }

  void navigateToHome() {
    _stageService.updateSelectedBottomNavIndex(0); // Home tab is at index 0
  }

  // Getter for current tickets based on selected tab
  List<TicketModel> get currentTickets {
    return selectedTabIndex == 0 ? activeTickets : resolvedTickets;
  }

  // Getter for has more tickets based on selected tab
  bool get hasMoreTickets {
    return selectedTabIndex == 0 ? hasMoreActive : hasMoreResolved;
  }
}
