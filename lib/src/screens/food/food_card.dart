import 'package:flutter/material.dart';
import 'package:zero_desperdicio/src/data/mock_repository.dart';
import 'package:zero_desperdicio/src/models/doacao_model.dart';
import 'package:zero_desperdicio/src/models/usuario_model.dart';
import 'package:zero_desperdicio/src/services/auth_service.dart';

class FoodCard extends StatefulWidget {
  final Doacao item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const FoodCard({super.key, required this.item, this.onTap, this.onDelete});

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  Usuario? _creator;
  bool _loading = true;

  bool get _isOwner {
    final user = AuthService.instance.currentUser.value;
    if (user == null) return false;
    return user.id == widget.item.idUsuarioDoa.toString();
  }

  @override
  void initState() {
    super.initState();
    _loadCreator();
  }

  Future<void> _loadCreator() async {
    await MockRepository.instance.init();
    final users = MockRepository.instance.allUsuarios();
    try {
      final found =
          users.firstWhere((u) => u.id == widget.item.idUsuarioDoa);
      setState(() {
        _creator = found;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.item.alimento.imageUrl;
    final isOng = _creator?.tipo == 'ong';

    return InkWell(
      onTap: widget.onTap,
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
                  color: Colors.green.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // imagem
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 72,
                      height: 72,
                      color: Colors.white24,
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Center(child: Icon(Icons.fastfood, color: Colors.white, size: 32)),
                            )
                          : const Center(child: Icon(Icons.fastfood, color: Colors.white, size: 32)),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.item.alimento.nome,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(widget.item.alimento.descricao,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                          'Validade: ${widget.item.alimento.validade.day}/${widget.item.alimento.validade.month}/${widget.item.alimento.validade.year}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Quantidade: ${widget.item.quantidade}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  if (_isOwner && widget.onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white),
                      onPressed: widget.onDelete,
                    ),
                ],
              ),
            ),
          ),

          // selo “Minha”
          if (_isOwner)
            Positioned(
              right: 12,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Minha',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
            ),

          // selo “ONG” (se doador for tipo ONG)
          if (isOng)
            Positioned(
              left: 12,
              top: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.favorite, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'ONG',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
