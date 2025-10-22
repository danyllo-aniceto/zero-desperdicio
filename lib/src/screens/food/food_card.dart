import 'package:flutter/material.dart';
import 'package:zero_desperdicio/src/models/doacao_model.dart';
import 'package:zero_desperdicio/src/services/auth_service.dart';

class FoodCard extends StatelessWidget {
  final Doacao item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const FoodCard({super.key, required this.item, this.onTap, this.onDelete});

  bool get _isOwner {
    final user = AuthService.instance.currentUser.value;
    if (user == null) return false;
    // comparando id (AuthService tem id como String no exemplo anterior)
    return user.id == item.idUsuarioDoa.toString();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.alimento.imageUrl;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem (se tiver) ou ícone
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 72,
                      height: 72,
                      color: Colors.white24,
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Center(child: Icon(Icons.fastfood, color: Colors.white, size: 32)),
                            )
                          : const Center(child: Icon(Icons.fastfood, color: Colors.white, size: 32)),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Texto principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.alimento.nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.alimento.descricao,
                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Validade: ${item.alimento.validade.day}/${item.alimento.validade.month}/${item.alimento.validade.year}',
                          style: const TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Quantidade: ${item.quantidade}',
                          style: const TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  // Botão de deletar só aparece se eu for dono da doação
                  if (_isOwner && onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white),
                      onPressed: onDelete,
                      tooltip: 'Remover minha doação',
                    ),
                ],
              ),
            ),
          ),

          // Badge "Minha" no canto superior direito quando for minha doação
          if (_isOwner)
            Positioned(
              right: 12,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Minha',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
