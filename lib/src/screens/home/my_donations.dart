import 'package:flutter/material.dart';

class MyDonationsScreen extends StatelessWidget {
  const MyDonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // dummy histórico
    final history = List.generate(5, (i) => 'Transação ${i + 1} - ${DateTime.now().subtract(Duration(days: i)).toLocal()}');
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas doações / recebimentos')),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: history.length,
        itemBuilder: (context, i) => Card(child: ListTile(title: Text(history[i]))),
      ),
    );
  }
}
