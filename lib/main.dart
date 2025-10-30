import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zero_desperdicio/src/app.dart';
import 'package:zero_desperdicio/src/data/mock_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // tenta inicializar o repositório mock — captura erro para não quebrar a UI
  try {
    await MockRepository.instance.init();
  } catch (e, st) {
    // tenta resetar caso algo corrompido, e loga
    // ignore: avoid_print
    print('MockRepository.init failed: $e\n$st');
    try {
      await MockRepository.instance.init(forceReset: true);
    } catch (e2, st2) {
      // se ainda falhar, apenas logue — app continuará mas sem dados persistidos
      // ignore: avoid_print
      print('MockRepository.init (forceReset) failed: $e2\n$st2');
    }
  }

  runApp(const ProviderScope(child: App()));
}
