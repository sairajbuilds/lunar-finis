import '../../../models/fund.dart';

abstract class FundsState {}

class StateFundsInitial extends FundsState {}

class StateFundsLoading extends FundsState {}

class StateFundsLoaded extends FundsState {
  final List<Fund> funds;

  StateFundsLoaded(this.funds);
}

class StateFundsFailure extends FundsState {
  final String message;

  StateFundsFailure(this.message);
}
