import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/core/models/rating_ticket_list_model.dart';
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

class FeedbackRatingsViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();
  final _ticketService = locator<TicketService>();

  // Search query
  String _searchQuery = '';

  // Pagination state
  final ReactiveValue<int> _resolvedPage = ReactiveValue<int>(1);
  final ReactiveValue<bool> _hasMoreActive = ReactiveValue<bool>(true);
  final ReactiveValue<bool> _hasMoreResolved = ReactiveValue<bool>(true);
  final ReactiveValue<bool> _isLoadingMore = ReactiveValue<bool>(false);

  int get resolvedPage => _resolvedPage.value;

  bool get hasMoreActive => _hasMoreActive.value;

  bool get hasMoreResolved => _hasMoreResolved.value;

  bool get isLoadingMore => _isLoadingMore.value;

  final ReactiveValue<List<RatingList>> _resolvedTickets = ReactiveValue<List<RatingList>>([]);
  final ReactiveValue<bool> _isLoading = ReactiveValue<bool>(false);

  // Filtered tickets for search
  final ReactiveValue<List<RatingList>> _filteredResolvedTickets = ReactiveValue<List<RatingList>>([]);

  List<RatingList> get resolvedTickets => _filteredResolvedTickets.value;

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
      _resolvedPage.value = 1;
      _hasMoreActive.value = true;
      _hasMoreResolved.value = true;
      _resolvedTickets.value = [];
    }
      await _loadResolvedTickets();
  }

  Future<void> _loadResolvedTickets() async {
    if (_isLoading.value) return;

    _isLoading.value = true;
    notifyListeners();

    try {
      final resolvedResult = await _ticketService.getTicketRatingList(
        status: 'Resolved',
        page: _resolvedPage.value,
        limit: 5,
        forceRefresh: _resolvedPage.value == 1,
      );

      List<RatingList> combinedTickets = [];

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
        _resolvedPage.value++;
        await _loadResolvedTickets();

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
      _filteredResolvedTickets.value = _resolvedTickets.value;
    } else {
      // Filter tickets based on search query
      final query = _searchQuery.toLowerCase();

      _filteredResolvedTickets.value =
          _resolvedTickets.value.where((ticket) {
            return _matchesSearchQuery(ticket, query);
          }).toList();
    }
    notifyListeners();
  }

  bool _matchesSearchQuery(RatingList ticket, String query) {
    final fullName = ticket.processor?.fullName?.toLowerCase() ?? '';

    return fullName.contains(query);
  }

  void resetFilters() {
    _searchQuery = '';
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

  void navigateBack() {
    _navigationService.back();
  }

  // Getter for has more tickets based on selected tab
  bool get hasMoreTickets {
    return hasMoreResolved;
  }
}
