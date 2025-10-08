import 'package:flutter/material.dart';

/// Define as constantes de cores utilizadas em todo o aplicativo.
class AppColors {
  // Cores Primárias e de Destaque
  // Verde Sálvia (Celadon) para o tema principal, sugerindo natureza e calma.
  static const primary = Color(0xFF8FBC8F); // Medium Sea Green / Dark Sea Green (Sálvia/Celadon)
  static const primaryDark = Color(0xFF6B8E6B); // Um tom mais escuro da Sálvia para contraste
  static const accent = Color(0xFFFFD700); // Amarelo Dourado (Gold) para destaque (alimentos)
  static const secondary = Color(0xFFADD8E6); // Light Blue (Para fundos ou secundários)

  // Cores de Superfície e Fundo
  static const background = Color(0xFFF0FFF0); // Honeydew (Fundo bem suave)
  static const surface = Colors.white; // Superfícies de Cards/Botões
  
  // Cores de Texto e Feedback
  static const textPrimary = Color(0xFF222222);
  static const textSecondary = Color(0xFF666666);
  static const danger = Color(0xFFDC143C); // Crimson (Para erros ou alertas)
}

/// Define o tema geral do aplicativo.
class AppTheme {
  static final lightTheme = ThemeData(
    // Cores Principais
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.danger,
    ),
    scaffoldBackgroundColor: AppColors.background,

    // Configurações de Tipografia (usando 'Roboto' ou a fonte padrão do Flutter)
    textTheme: const TextTheme(
      // Títulos grandes, como em AppBar
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      // Títulos de seção
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      // Corpo do texto
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textPrimary),
    ),
    
    // Estilo dos Botões Elevados
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface, // Texto do botão branco
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)), // Cantos mais arredondados
        ),
        elevation: 4,
      ),
    ),

    // Estilo dos Botões de Texto (TextButton)
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
      ),
    ),

    // Estilo dos Cards (para Doadores e ONGs)
    // CORREÇÃO: A propriedade cardTheme espera um CardThemeData (que é a mesma classe CardTheme)
    // ou CardTheme, dependendo da versão. Vou usar o CardTheme diretamente.
    
    // Configuração do AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.surface, // Ícones e texto brancos
      elevation: 0,
    ),
  );
}
