part of 'ticket_card.dart';

class TicketCardAttributes {
  final String name;
  final String id;
  final String machineName;
  final String priorityLevel;
  final String createdBy;
  final String timeElapsed;
  final String lastUpdated;
  final Function(String) onMarkClosed;
  TicketCardAttributes({
    required this.name,
    required this.id,
    required this.machineName,
    required this.priorityLevel,
    required this.createdBy,
    required this.timeElapsed,
    required this.lastUpdated,
    required this.onMarkClosed,
  });
}
