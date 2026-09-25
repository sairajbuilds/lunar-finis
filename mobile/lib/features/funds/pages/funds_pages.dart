import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/utils/constants.dart';
import 'package:mobile/features/auth/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/bloc/auth_event.dart';
import 'package:mobile/features/basket/bloc/basket_bloc.dart';
import 'package:mobile/features/basket/bloc/basket_event.dart';
import 'package:mobile/features/basket/bloc/basket_state.dart'
    show BasketState, StateBasketFailure, StateBasketLoaded;
import 'package:mobile/features/basket/pages/basket_page.dart';
import 'package:mobile/repositories/basket_repository.dart';

import '../../../core/network/api_client.dart';
import '../../../repositories/funds_repository.dart';
import '../bloc/funds_bloc.dart';
import '../bloc/funds_event.dart';
import '../bloc/funds_state.dart';

class FundsPage extends StatelessWidget {
  const FundsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient(baseUrl: API_URL);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              FundsBloc(FundsRepository(apiClient))..add(EventLoadFunds()),
        ),
        BlocProvider(
          create: (_) =>
              BasketBloc(BasketRepository(apiClient))..add(EventLoadBasket()),
        ),
      ],
      child: const _FundsView(),
    );
  }
}

class _FundsView extends StatefulWidget {
  const _FundsView();

  @override
  State<_FundsView> createState() => _FundsViewState();
}

class _FundsViewState extends State<_FundsView> {
  String? _addingFundId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<BasketBloc, BasketState>(
      listener: (context, state) {
        if (state is StateBasketFailure) {
          setState(() {
            _addingFundId = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message.replaceFirst('Exception: ', '')),
            ),
          );
        }

        if (state is StateBasketLoaded && _addingFundId != null) {
          setState(() {
            _addingFundId = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fund added to your basket')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mutual Funds'),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_basket_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<BasketBloc>(),
                      child: const BasketPage(),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(EventLogoutRequested());
              },
            ),
          ],
        ),
        body: BlocBuilder<FundsBloc, FundsState>(
          builder: (context, state) {
            if (state is StateFundsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is StateFundsFailure) {
              return Center(child: Text(state.message));
            }

            if (state is StateFundsLoaded) {
              if (state.funds.isEmpty) {
                return const Center(child: Text('No funds available'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.funds.length,
                itemBuilder: (context, index) {
                  final fund = state.funds[index];

                  final isAdding = _addingFundId == fund.id;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fund.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text('Category: ${fund.category}'),
                          Text('3Y Return: ${fund.threeYearReturn}%'),
                          Text('Expense Ratio: ${fund.expenseRatio}%'),
                          Text('Risk: ${fund.riskLevel}'),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isAdding
                                  ? null
                                  : () {
                                      setState(() {
                                        _addingFundId = fund.id;
                                      });

                                      context.read<BasketBloc>().add(
                                        EventAddFund(fund.id),
                                      );
                                    },
                              child: isAdding
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Add to Basket'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
