import '../../../models/fund.dart';

abstract class BasketState {}

class StateBasketInitial extends BasketState {}

class StateBasketLoading extends BasketState {
  final List<Fund> funds;

  StateBasketLoading([this.funds = const []]);
}

class StateBasketLoaded extends BasketState {
  final List<Fund> funds;

  StateBasketLoaded(this.funds);
}

class StateBasketFailure extends BasketState {
  final String message;
  final List<Fund> funds;

  StateBasketFailure(this.message, [this.funds = const []]);
}
