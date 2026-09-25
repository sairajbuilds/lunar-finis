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
            return const Center(child: Text('Your basket is empty'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: funds.length,
            itemBuilder: (context, index) {
              final fund = funds[index];
              final isRemoving = _removingFundId == fund.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(fund.name),
                  subtitle: Text(
                    '${fund.category} • ${fund.threeYearReturn}% 3Y return',
                  ),
                  trailing: isRemoving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() {
                              _removingFundId = fund.id;
                            });

                            context.read<BasketBloc>().add(
                              EventRemoveFund(fund.id),
                            );
                          },
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
