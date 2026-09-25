abstract class BasketEvent {}

class EventLoadBasket extends BasketEvent {}

class EventAddFund extends BasketEvent {
  final String fundId;

  EventAddFund(this.fundId);
}

class EventRemoveFund extends BasketEvent {
  final String fundId;

  EventRemoveFund(this.fundId);
}
