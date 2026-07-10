enum NotificationType {
  newOffer,
  offerAccepted,
  newMessage,
  requestCompleted;

  static NotificationType fromDb(String value) {
    switch (value) {
      case 'new_offer':
        return NotificationType.newOffer;
      case 'offer_accepted':
        return NotificationType.offerAccepted;
      case 'new_message':
        return NotificationType.newMessage;
      case 'request_completed':
        return NotificationType.requestCompleted;
      default:
        throw ArgumentError('Unknown notification type: $value');
    }
  }
}
