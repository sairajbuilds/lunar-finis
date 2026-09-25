import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/basket_bloc.dart';
import '../bloc/basket_event.dart';
import '../bloc/basket_state.dart';

class BasketPage extends StatefulWidget {
  const BasketPage({super.key});

  @override
  State<BasketPage> createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  String? _removingFundId;

  String _capitalize(String value) {
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Basket')),
      body: BlocConsumer<BasketBloc, BasketState>(
        listener: (context, state) {
          if (state is StateBasketFailure) {
            setState(() {
              _removingFundId = null;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.replaceFirst('Exception: ', '')),
              ),
            );
          }

          if (state is StateBasketLoaded && _removingFundId != null) {
            setState(() {
              _removingFundId = null;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fund removed from your basket')),
            );
          }
        },
        builder: (context, state) {
          // Initial basket loading
          if (state is StateBasketLoading && state.funds.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final funds = switch (state) {
            StateBasketLoaded(:final funds) => funds,
            StateBasketLoading(:final funds) => funds,
            StateBasketFailure(:final funds) => funds,
            _ => [],
          };

          if (funds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_basket_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your basket is empty',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add mutual funds from the funds list.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: funds.length,
            itemBuilder: (context, index) {
              final fund = funds[index];
              final isRemoving = _removingFundId == fund.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('3Y Return'),
                          Text(
                            '${fund.threeYearReturn}%',
                            style: const TextStyle(fontWeight: FontWeight.w600),
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
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isRemoving
                              ? null
                              : () {
                                  setState(() {
                                    _removingFundId = fund.id;
                                  });

                                  context.read<BasketBloc>().add(
                                    EventRemoveFund(fund.id),
                                  );
                                },
                          icon: isRemoving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.delete_outline),
                          label: Text(
                            isRemoving ? 'Removing...' : 'Remove from Basket',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
