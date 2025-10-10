import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/routes/routes.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:manager/features/tickets/ticket_details/ticket_details.view.dart';

import '../../../api_endpoints.dart';
import '../../../core/locator.dart';
import '../../../core/models/ticket_model.dart';
import '../../../core/utils/app_logger.dart';
import '../../../services/api.service.dart';
import '../../../services/ticket.service.dart';
import '../../../services/stage.service.dart';

class TicketsListViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _ticketService = locator<TicketService>();
  final _stageService = locator<StageService>();
  final _apiService = locator<ApiService>();

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
  final ReactiveValue<List<TicketList>> _activeTickets = ReactiveValue<List<TicketList>>([]);
  final ReactiveValue<List<TicketList>> _resolvedTickets = ReactiveValue<List<TicketList>>([]);
  final ReactiveValue<bool> _isLoading = ReactiveValue<bool>(false);

  // Filtered tickets for search
  final ReactiveValue<List<TicketList>> _filteredActiveTickets = ReactiveValue<List<TicketList>>([]);
  final ReactiveValue<List<TicketList>> _filteredResolvedTickets = ReactiveValue<List<TicketList>>([]);

  List<TicketList> get activeTickets => _filteredActiveTickets.value;

  List<TicketList> get resolvedTickets => _filteredResolvedTickets.value;

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
      await loadActiveTickets();
    } else {
      await _loadResolvedTickets();
    }
  }

  Future<void> loadActiveTickets() async {
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

      List<TicketList> combinedTickets = [];

      activeResult.fold(
        (failure) {
          print('Error loading active tickets: ${failure.message}');
        },
        (paginatedResponse) {
          combinedTickets.addAll(paginatedResponse.data ?? []);
        },
      );

      if (_activePage.value == 1) {
        _activeTickets.value = combinedTickets;
      } else {
        _activeTickets.value = [..._activeTickets.value, ...combinedTickets];
      }

      // Check if we have more tickets from either status
      bool hasMoreActive = false;

      activeResult.fold((failure) {}, (paginatedResponse) {
        hasMoreActive = _activePage.value < (paginatedResponse.pages ?? 1);
      });
      _hasMoreActive.value = hasMoreActive;
    } catch (e) {
      print('Exception loading active tickets: $e');
      if (_activePage.value == 1) {
        _activeTickets.value = [];
      }
    }

    // Update filtered tickets after loading
    _applySearchFilters();
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

      List<TicketList> combinedTickets = [];

      resolvedResult.fold(
        (failure) {
          print('Error loading resolved tickets: ${failure.message}');
        },
        (paginatedResponse) {
          combinedTickets.addAll(paginatedResponse.data ?? []);
        },
      );

      if (_resolvedPage.value == 1) {
        _resolvedTickets.value = combinedTickets;
      } else {
        _resolvedTickets.value = [..._resolvedTickets.value, ...combinedTickets];
      }

      // Check if we have more tickets from either status
      bool hasMoreResolved = false;

      resolvedResult.fold((failure) {}, (paginatedResponse) {
        hasMoreResolved = _resolvedPage.value < (paginatedResponse.pages ?? 1);
      });

      _hasMoreResolved.value = hasMoreResolved;
    } catch (e) {
      print('Exception loading resolved tickets: $e');
      if (_resolvedPage.value == 1) {
        _resolvedTickets.value = [];
      }
    }

    // Update filtered tickets after loading
    _applySearchFilters();
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
        await loadActiveTickets();
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
    if (_searchQuery.isEmpty) {
      _filteredActiveTickets.value = _activeTickets.value;
      _filteredResolvedTickets.value = _resolvedTickets.value;
    } else {
      // Filter tickets based on search query
      final query = _searchQuery.toLowerCase();

      _filteredActiveTickets.value =
          _activeTickets.value.where((ticket) {
            return _matchesSearchQuery(ticket, query);
          }).toList();

      _filteredResolvedTickets.value =
          _resolvedTickets.value.where((ticket) {
            return _matchesSearchQuery(ticket, query);
          }).toList();
    }
    notifyListeners();
  }

  bool _matchesSearchQuery(TicketList ticket, String query) {
    final fullName = ticket.processor?.fullName?.toLowerCase() ?? '';

    return fullName.contains(query);
  }

  void resetFilters() {
    _searchQuery = '';
    _filteredActiveTickets.value = _activeTickets.value;
    _filteredResolvedTickets.value = _resolvedTickets.value;
    notifyListeners();
  }

  void navigateToTicketDetails({required String ticketId, required BuildContext context}) async {
    // Navigate to ticket details and wait for result
    final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => TicketDetailsView(ticketId: ticketId)));

    // Refresh tickets when returning from ticket details
    if (result == true || result == null) {
      await loadTickets(forceRefresh: true);
    }
  }

  void navigateToReviewTicketWithId({required String ticketId}) async {
    await _navigationService.navigateTo(Routes.reviewTicket, arguments: ticketId);
  }

  void navigateToHome() {
    _stageService.updateSelectedBottomNavIndex(0); // Home tab is at index 0
  }

  // Getter for current tickets based on selected tab
  List<TicketList> get currentTickets {
    return selectedTabIndex == 0 ? activeTickets : resolvedTickets;
  }

  // Getter for has more tickets based on selected tab
  bool get hasMoreTickets {
    return selectedTabIndex == 0 ? hasMoreActive : hasMoreResolved;
  }

  Future<void> createTicket({
    String? problem,
    String? errorCode,
    String? additionalNotes,
    List<File>? attachments,
    String? maintenanceType,
    bool isFromSiteVisit = false,
    String? machineId,
    String? organizationId,
  }) async {
    if (machineId == null) {
      AppLogger.error('Machine ID is null');
      Fluttertoast.showToast(msg: 'Machine ID not found', backgroundColor: Colors.red);
      return;
    }

    if (organizationId == null) {
      AppLogger.error('Organization ID is null');
      Fluttertoast.showToast(msg: 'Organization ID not found', backgroundColor: Colors.red);
      return;
    }

    if (isFromSiteVisit) {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('ticketType', maintenanceType!),
        MapEntry('machineId', machineId),
        MapEntry('organisationId', organizationId),
        MapEntry('problem', ""),
        MapEntry('errorCode', ""),
        MapEntry('notes', ""),
        MapEntry('paymentStatus', "unpaid"),
        MapEntry('type', "Offline"),
      ]);

      final response = await _apiService.post(url: ApiEndpoints.createTicket, data: formData);

      if (response.statusCode == 201 && response.data['ticket'] != null) {
        final ticketId = response.data['ticket']['_id'];

        AppLogger.info('Site visit ticket created successfully: ${response.data['ticket']['_id']}');

        await _navigationService.navigateTo(Routes.reviewTicket, arguments: ticketId);

        Fluttertoast.showToast(msg: response.data["message"] ?? 'Site visit ticket created successfully!', backgroundColor: Colors.green);
      } else {
        AppLogger.error('Failed to create site visit ticket');
      }
    } else {
      final formData = FormData();

      formData.fields.addAll([
        MapEntry('problem', problem!),
        MapEntry('errorCode', errorCode!),
        MapEntry('notes', additionalNotes!),
        MapEntry('machineId', machineId),
        MapEntry('organisationId', organizationId),
        MapEntry('ticketType', "Full Machine Service"),
        MapEntry('paymentStatus', "unpaid"),
        MapEntry('type', "Online"),
      ]);

      for (var i = 0; i < attachments!.length; i++) {
        final file = attachments[i];
        final extension = file.path.split('.').last.toLowerCase();
        final contentType = extension == 'png' ? DioMediaType('image', 'png') : DioMediaType('image', 'jpeg');
        formData.files.add(
          MapEntry('ticketImages', await MultipartFile.fromFile(file.path, filename: 'ticket_image_$i.$extension', contentType: contentType)),
        );
      }

      final response = await _apiService.post(url: ApiEndpoints.createTicket, data: formData);

      if (response.statusCode == 201 && response.data['ticket'] != null) {
        final ticketId = response.data['ticket']['_id'];

        AppLogger.info('Ticket created successfully: ${response.data['ticket']['_id']}');
        await _navigationService.navigateTo(Routes.reviewTicket, arguments: ticketId);
        Fluttertoast.showToast(msg: response.data["message"] ?? 'Ticket created successfully!', backgroundColor: Colors.green);
      } else {
        AppLogger.error('Failed to create ticket');
      }
    }
  }
}
