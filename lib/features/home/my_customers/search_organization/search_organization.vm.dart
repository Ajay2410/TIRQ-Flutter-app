import 'package:stacked/stacked.dart';

class SearchOrganizationViewModel extends BaseViewModel {
  List<Map<String, String>> _searchResults = [];
  String _searchQuery = '';

  // Mock data for demonstration - replace with actual API call
  final List<Map<String, String>> _allOrganizations = [
    {
      'name': 'Leslie Alexander',
      'avatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      'phone': '+1234567890',
      'email': 'leslie@example.com',
    },
    {
      'name': 'Raj Patel',
      'avatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
      'phone': '+1987654321',
      'email': 'raj@example.com',
    },
    {
      'name': 'Deep Singh',
      'avatar':
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
      'phone': '+1122334455',
      'email': 'deep@example.com',
    },
    {
      'name': 'Sarah Johnson',
      'avatar':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face',
      'phone': '+1555666777',
      'email': 'sarah@example.com',
    },
    {
      'name': 'Mike Chen',
      'avatar':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop&crop=face',
      'phone': '+1888999000',
      'email': 'mike@example.com',
    },
    {
      'name': 'Emma Wilson',
      'avatar':
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop&crop=face',
      'phone': '+1777888999',
      'email': 'emma@example.com',
    },
    {
      'name': 'Alex Brown',
      'avatar':
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100&h=100&fit=crop&crop=face',
      'phone': '+1666777888',
      'email': 'alex@example.com',
    },
    {
      'name': 'Lisa Davis',
      'avatar':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop&crop=face',
      'phone': '+1444555666',
      'email': 'lisa@example.com',
    },
  ];

  List<Map<String, String>> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void performSearch(String query) {
    if (query.isEmpty || query.trim().isEmpty) {
      _searchResults.clear();
    } else {
      final trimmedQuery = query.trim().toLowerCase();

      // Search in name, phone, and email
      _searchResults =
          _allOrganizations.where((org) {
            final name = org['name']?.toLowerCase() ?? '';
            final phone = org['phone']?.toLowerCase() ?? '';
            final email = org['email']?.toLowerCase() ?? '';

            // Check if query matches name (partial match)
            if (name.contains(trimmedQuery)) return true;

            // Check if query matches phone (exact or partial match)
            if (phone.contains(trimmedQuery)) return true;

            // Check if query matches email (partial match)
            if (email.contains(trimmedQuery)) return true;

            // Check if query matches avatar initials
            final avatar = org['avatar']?.toLowerCase() ?? '';
            if (avatar.contains(trimmedQuery)) return true;

            return false;
          }).toList();

      // Sort results: exact matches first, then partial matches
      _searchResults.sort((a, b) {
        final aName = a['name']?.toLowerCase() ?? '';
        final bName = b['name']?.toLowerCase() ?? '';

        // Exact matches first
        if (aName == trimmedQuery && bName != trimmedQuery) return -1;
        if (bName == trimmedQuery && aName != trimmedQuery) return 1;

        // Then by name similarity (starts with query)
        final aStartsWith = aName.startsWith(trimmedQuery);
        final bStartsWith = bName.startsWith(trimmedQuery);

        if (aStartsWith && !bStartsWith) return -1;
        if (!aStartsWith && bStartsWith) return 1;

        // Finally by alphabetical order
        return aName.compareTo(bName);
      });
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults.clear();
    notifyListeners();
  }
}
