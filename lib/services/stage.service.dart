import 'package:stacked/stacked.dart';

class StageService with ListenableServiceMixin {

  ReactiveValue<bool> isCloseTicketDialogOpen = ReactiveValue(false);

  ReactiveValue<String?> requestedTicketId = ReactiveValue(null);

  setCloseTicketDialogOpen(bool val,String? ticketId) {
    isCloseTicketDialogOpen.value = val;
    if(ticketId!=null){
      requestedTicketId.value = ticketId;
    }
    notifyListeners();
  }
}