import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/food_item.dart';
import '../../providers/food_list_provider.dart';

class FoodDetailScreen extends ConsumerWidget {
  final FoodItem item;
  const FoodDetailScreen({super.key, required this.item});

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = item.daysToExpiry();
    final expiryText = days >= 0 ? '$days dias restantes' : 'Vencido';
    final isUrgent = days >= 0 && days <= 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // imagem / placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: item.photo != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(item.photo!, fit: BoxFit.cover),
                    )
                  : const Center(
                      child: Icon(Icons.fastfood, size: 64, color: Colors.grey),
                    ),
            ),
            const SizedBox(height: 16),

            // título + tipo
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(item.type.toUpperCase()),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // quantidades / validade
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 18, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text('Quantidade: ${item.quantity}'),
                const SizedBox(width: 16),
                Icon(Icons.event, size: 18, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text('Validade: ${_formatDate(item.expiryDate)}'),
              ],
            ),

            const SizedBox(height: 12),

            // destaque de validade
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isUrgent ? Colors.red.withOpacity(0.08) : Colors.grey.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                expiryText,
                style: TextStyle(
                  color: isUrgent ? Colors.red : Colors.black87,
                  fontWeight: isUrgent ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // localização (se existir)
            if (item.lat != null && item.lon != null) ...[
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text('Localização: ${item.lat!.toStringAsFixed(4)}, ${item.lon!.toStringAsFixed(4)}'),
                ],
              ),
              const SizedBox(height: 12),
            ],

            const Divider(),

            const SizedBox(height: 8),

            const Text(
              'Descrição',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Sem descrição detalhada (mock). Aqui você pode colocar informações adicionais como estado do alimento, embalagem, observações e condições para retirada.',
              style: TextStyle(color: Colors.black87),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      // botões na parte inferior
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.favorite_outline),
                label: const Text('Doar'),
                onPressed: () => _confirmDonate(context, ref),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Trocar'),
                onPressed: () => _openTradeSheet(context),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _schedulePickup(context),
              icon: const Icon(Icons.calendar_month_outlined),
              tooltip: 'Agendar',
            ),
          ],
        ),
      ),
    );
  }

  // confirma doação -> remove o item do provider e retorna um resultado ao Home
  Future<void> _confirmDonate(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar doação'),
        content: Text('Deseja confirmar a doação de "${item.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmar')),
        ],
      ),
    );

    if (confirmed == true) {
      // remove do repositório (mock) e volta para a Home informando o resultado
      await ref.read(foodListProvider.notifier).remove(item.id);
      Navigator.pop(context, 'donated'); // o Home receberá este resultado e pode mostrar SnackBar
    }
  }

  // abre um bottom sheet para enviar proposta de troca (mock)
  Future<void> _openTradeSheet(BuildContext context) async {
    final controller = TextEditingController();
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Proposta de troca para "${item.name}"', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Escreva sua proposta (ex: posso trocar por arroz 5kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Proposta de troca enviada (mock)')),
                    );
                  },
                  child: const Text('Enviar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // agendar coleta/retirada (usa date & time pickers)
  Future<void> _schedulePickup(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;

    final scheduled = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final formatted = '${scheduled.day.toString().padLeft(2, '0')}/${scheduled.month.toString().padLeft(2, '0')}/${scheduled.year} ${time.format(context)}';

    // mock: apenas informar ao usuário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Agendamento mock realizado para $formatted')),
    );
  }
}
