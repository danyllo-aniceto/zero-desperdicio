import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zero_desperdicio/src/models/doacao_model.dart';
import 'package:zero_desperdicio/src/services/mock_service.dart';
import 'package:zero_desperdicio/src/models/usuario_model.dart';

enum SendMethod { whatsapp, email }

class ComposeMessageScreen extends StatefulWidget {
  final Doacao doacao;
  /// action: 'receber' ou 'doar' (apenas para template)
  final String action;

  const ComposeMessageScreen({super.key, required this.doacao, required this.action});

  @override
  State<ComposeMessageScreen> createState() => _ComposeMessageScreenState();
}

class _ComposeMessageScreenState extends State<ComposeMessageScreen> {
  late TextEditingController _ctrl;
  SendMethod _method = SendMethod.whatsapp;
  Usuario? _recipient;

  @override
  void initState() {
    super.initState();
    _recipient = _findRecipient();
    final template = _buildTemplate();
    _ctrl = TextEditingController(text: template);
  }

  Usuario? _findRecipient() {
    try {
      return MockService.usuarios.firstWhere((u) => u.id == widget.doacao.idUsuarioDoa);
    } catch (e) {
      return null;
    }
  }

  String _buildTemplate() {
    final item = widget.doacao.alimento.nome;
    final donorName = _recipient?.nomeUsuario ?? 'responsável';
    final contactHint = ''; // você pode inserir o próprio contato aqui se quiser
    if (widget.action == 'receber') {
      return 'Olá $donorName,\n\nVi sua doação de "$item" no Zero Desperdício e tenho interesse em receber. Podemos combinar a retirada/entrega?\n\n$contactHint\n\nObrigado!';
    } else {
      // action == 'doar'
      return 'Olá $donorName,\n\nVi seu anúncio sobre "$item" no Zero Desperdício. Gostaria de oferecer/doar/trocar (escreva aqui os detalhes). Podemos combinar?\n\n$contactHint\n\nObrigado!';
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escreva a mensagem antes de enviar.')));
      return;
    }

    // Buscar contato do destinatário
    final recipient = _recipient;
    final email = recipient?.email;
    final phoneRaw = recipient?.tel; // tal como mock (ex: '11999999999')
    String phone = '';
    if (phoneRaw != null) {
      // remover caracteres não-dígitos (apenas para deixar mais seguro)
      phone = phoneRaw.replaceAll(RegExp(r'\D'), '');
    }

    if (_method == SendMethod.email) {
      if (email == null || email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email do destinatário não disponível.')));
        return;
      }
      final subject = Uri.encodeComponent('Contato via Zero Desperdício');
      final body = Uri.encodeComponent(text);
      final uri = Uri.parse('mailto:$email?subject=$subject&body=$body');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        Navigator.pop(context); // voltar depois de abrir o app de email
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível abrir o app de email.')));
      }
    } else {
      // WhatsApp
      if (phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Número do destinatário não disponível.')));
        return;
      }

      // Tenta usar wa.me com número (sem +). Se quiser forçar +55, ajuste aqui.
      final encoded = Uri.encodeComponent(text);
      final uri = Uri.parse('https://wa.me/$phone?text=$encoded');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        Navigator.pop(context);
      } else {
        // fallback com whatsapp://send?text=...&phone=...
        final fallback = Uri.parse('whatsapp://send?phone=$phone&text=$encoded');
        if (await canLaunchUrl(fallback)) {
          await launchUrl(fallback);
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')));
        }
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipientName = _recipient?.nomeUsuario ?? 'Responsável';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.action == 'receber' ? 'Solicitar (Quero receber)' : 'Oferecer (Quero doar)'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Info do destinatário
            Row(
              children: [
                const Icon(Icons.person, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text('Para: $recipientName', style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 12),

            // Campo editável com template
            Expanded(
              child: TextFormField(
                controller: _ctrl,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Escolha do método
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: Radio<SendMethod>(value: SendMethod.whatsapp, groupValue: _method, onChanged: (v) => setState(() => _method = v!)),
                    title: const Text('WhatsApp'),
                    subtitle: Text(_recipient?.tel ?? 'Número não disponível'),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    leading: Radio<SendMethod>(value: SendMethod.email, groupValue: _method, onChanged: (v) => setState(() => _method = v!)),
                    title: const Text('Email'),
                    subtitle: Text(_recipient?.email ?? 'Email não disponível'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
