import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/basket_bloc.dart';
import '../bloc/basket_event.dart';
import '../bloc/basket_state.dart';

class BasketPage extends StatelessWidget {
  const BasketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Basket')),
      body: BlocConsumer<BasketBloc, BasketState>(
        listener: (context, state) {
          if (state is StateBasketFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
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

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(fund.name),
                  subtitle: Text(
                    '${fund.category} • ${fund.threeYearReturn}% 3Y return',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      context.read<BasketBloc>().add(EventRemoveFund(fund.id));
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
