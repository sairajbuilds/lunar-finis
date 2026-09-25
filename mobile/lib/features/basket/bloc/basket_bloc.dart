import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/models/fund.dart';

import '../../../repositories/basket_repository.dart';
import 'basket_event.dart';
import 'basket_state.dart';

class BasketBloc extends Bloc<BasketEvent, BasketState> {
  final BasketRepository repository;

  BasketBloc(this.repository) : super(StateBasketInitial()) {
    on<EventLoadBasket>(_onLoadBasket);
    on<EventAddFund>(_onAddFund);
    on<EventRemoveFund>(_onRemoveFund);
  }

  Future<void> _onLoadBasket(
    EventLoadBasket event,
    Emitter<BasketState> emit,
  ) async {
    emit(StateBasketLoading());

    try {
      final funds = await repository.getBasket();
      emit(StateBasketLoaded(funds));
    } catch (error) {
      emit(StateBasketFailure(error.toString()));
    }
  }

  // Future<void> _onAddFund(EventAddFund event, Emitter<BasketState> emit) async {
  //   final currentFunds = _currentFunds();

  //   emit(StateBasketLoading(currentFunds));

  //   try {
  //     await repository.addFund(event.fundId);

  //     final funds = await repository.getBasket();

  //     emit(StateBasketLoaded(funds));
  //   } catch (error) {
  //     emit(StateBasketFailure(error.toString(), currentFunds));
  //   }
  // }

  Future<void> _onAddFund(EventAddFund event, Emitter<BasketState> emit) async {
    final currentFunds = _currentFunds();

    emit(StateBasketLoading(currentFunds));

    try {
      print('ADDING FUND: ${event.fundId}');

      await repository.addFund(event.fundId);

      print('FUND ADDED: ${event.fundId}');

      final funds = await repository.getBasket();

      print('BASKET AFTER ADD: ${funds.length}');

      emit(StateBasketLoaded(funds));
    } catch (error) {
      print('ADD FUND ERROR: $error');

      emit(StateBasketFailure(error.toString(), currentFunds));
    }
  }

  Future<void> _onRemoveFund(
    EventRemoveFund event,
    Emitter<BasketState> emit,
  ) async {
    final currentFunds = _currentFunds();

    emit(StateBasketLoading(currentFunds));

    try {
      await repository.removeFund(event.fundId);

      final funds = await repository.getBasket();

      emit(StateBasketLoaded(funds));
    } catch (error) {
      emit(StateBasketFailure(error.toString(), currentFunds));
    }
  }

  List<Fund> _currentFunds() {
    final currentState = state;

    if (currentState is StateBasketLoaded) {
      return currentState.funds;
    }

    if (currentState is StateBasketLoading) {
      return currentState.funds;
    }

    if (currentState is StateBasketFailure) {
      return currentState.funds;
    }

    return [];
  }
}
