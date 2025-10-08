import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zero_desperdicio/src/screens/food/food_detail_screen.dart';
import '../../providers/food_list_provider.dart';
import '../../widgets/food_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foods = ref.watch(foodListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zero Desperdício'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // futuramente: navegar para cadastro
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tela de cadastro em breve!')),
              );
            },
          ),
        ],
      ),
      body: foods.isEmpty
          ? const Center(
              child: Text(
                'Nenhum alimento disponível.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(foodListProvider.notifier).load();
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: foods.length,
                itemBuilder: (context, i) {
                  final item = foods[i];
                  return FoodCard(
                    item: item,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FoodDetailScreen(item: item)),
                      );

                      if (result == 'donated') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Doação confirmada! Obrigado.')),
                        );
                      }
                    },
                    onDelete: () {
                       ref.read(foodListProvider.notifier).remove(item.id);
                    },
                  );
                },
              ),
            ),
    );
  }
}
