import 'package:flutter/material.dart';
import 'package:zero_desperdicio/src/models/user.dart';
import 'package:zero_desperdicio/src/screens/auth/login_screen.dart';
import 'package:zero_desperdicio/src/screens/food/food_form_screen.dart';
import 'package:zero_desperdicio/src/screens/food/food_list_screen.dart';
import 'package:zero_desperdicio/src/services/auth_service.dart';
import 'donate_form.dart';
import 'my_donations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final ValueNotifier<User?> userNotifier;

  int donatedCount = 12;
  int availableCount = 8;
  int myDonationsCount = 5;

  @override
  void initState() {
    super.initState();
    userNotifier = AuthService.instance.currentUser;
    userNotifier.addListener(_onUserChange);
  }

  void _onUserChange() => setState(() {});
  @override
  void dispose() {
    userNotifier.removeListener(_onUserChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = userNotifier.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Zero Desperdício'),
        centerTitle: true,
        elevation: 2,
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Text(
                  '${user.name} (${user.type.name})',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService.instance.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(builder: (context, constraints) {
          int columns = 1;
          if (constraints.maxWidth >= 1000) {
            columns = 3;
          } else if (constraints.maxWidth >= 700) {
            columns = 2;
          }

          return CustomScrollView(
            slivers: [
              // Sliver com o cabeçalho (rola junto)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Bem-vindo(a)! 💚',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Juntos contra o desperdício de alimentos.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),

              // Sliver com os cards (grid rolável)
              SliverGrid.count(
                crossAxisCount: columns,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.4,
                children: [
                  _ActionCard(
                    title: 'Quero doar',
                    subtitle: 'Cadastrar alimentos para doação',
                    count: donatedCount,
                    icon: Icons.volunteer_activism,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DonateFormScreen()),
                    ),
                  ),
                  _ActionCard(
                    title: 'Quero receber',
                    subtitle: 'Ver alimentos disponíveis',
                    count: availableCount,
                    icon: Icons.shopping_basket,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFA000), Color(0xFFFFD54F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FoodListScreen()),
                    ),
                  ),
                  _ActionCard(
                    title: 'Minhas doações',
                    subtitle: 'Histórico de doações e recebimentos',
                    count: myDonationsCount,
                    icon: Icons.history,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF81C784)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DonateFormScreen()),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// Card customizado com gradiente
class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.last.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 34, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 6),
                    Text(subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        )),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
