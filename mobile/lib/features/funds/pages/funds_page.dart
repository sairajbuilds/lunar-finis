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

  String _capitalize(String value) {
    return value[0].toUpperCase() + value.substring(1);
  }

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
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fund.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            '${_capitalize(fund.category)} · ${_capitalize(fund.riskLevel)} Risk',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('3Y Return'),
                              Text(
                                '${fund.threeYearReturn}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Expense Ratio'),
                              Text(
                                '${fund.expenseRatio}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

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
