import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repositories/funds_repository.dart';
import 'funds_event.dart';
import 'funds_state.dart';

class FundsBloc extends Bloc<FundsEvent, FundsState> {
  final FundsRepository repository;

  FundsBloc(this.repository) : super(StateFundsInitial()) {
    on<EventLoadFunds>(_onLoadFunds);
  }

  Future<void> _onLoadFunds(
    EventLoadFunds event,
    Emitter<FundsState> emit,
  ) async {
    emit(StateFundsLoading());

    try {
      final funds = await repository.getFunds();

      emit(StateFundsLoaded(funds));
    } catch (error) {
      emit(StateFundsFailure(error.toString()));
    }
  }
}
