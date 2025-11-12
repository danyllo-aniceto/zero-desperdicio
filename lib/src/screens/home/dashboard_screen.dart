import 'package:flutter/material.dart';
import 'package:zero_desperdicio/src/models/user.dart';
import 'package:zero_desperdicio/src/screens/home/donate_form.dart';
import 'package:zero_desperdicio/src/screens/home/my_donations.dart';
import 'package:zero_desperdicio/src/screens/loginAndRegister/login_screen.dart';
import 'package:zero_desperdicio/src/screens/food/food_list_screen.dart';
import 'package:zero_desperdicio/src/screens/user/user_profile_screen.dart';
import 'package:zero_desperdicio/src/services/auth_service.dart';
import 'package:zero_desperdicio/src/data/mock_repository.dart'; // IMPORT para ler os dados locais

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final ValueNotifier<User?> userNotifier;

  // Agora estes campos serão calculados em runtime
  int? donatedCount; // não usaremos no card "Quero doar" (vai ficar null)
  int availableCount = 0; // "Quero receber"
  int myDonationsCount = 0; // "Minhas doações" (histórico)

  @override
  void initState() {
    super.initState();
    userNotifier = AuthService.instance.currentUser;
    userNotifier.addListener(_onUserChange);
    // Carrega counts iniciais
    _loadCounts();
  }

  void _onUserChange() {
    // quando usuário muda, recalcular
    _loadCounts();
    setState(() {}); // atualiza UI com possível nome do usuário
  }

  @override
  void dispose() {
    userNotifier.removeListener(_onUserChange);
    super.dispose();
  }

  Future<void> _loadCounts() async {
    // inicializa o mock repo caso necessário
    await MockRepository.instance.init();

    final all = MockRepository.instance.allDoacoes();
    final user = userNotifier.value;
    final myId = user == null ? -1 : int.tryParse(user.id) ?? -1;

    // Disponíveis: não sou dono, não concluídas, não atribuídas (idUsuarioRec == 0)
    final available = all.where((d) {
      final isOwner = d.idUsuarioDoa == myId;
      final isConcluded = d.status.toLowerCase().contains('conclu');
      final isAssigned = d.idUsuarioRec != 0;
      return !isOwner && !isConcluded && !isAssigned;
    }).length;

    // Histórico/minhas doações: seu id e concluídas (mantendo comportamento do MyDonationsScreen)
    final mineConcluded = all.where((d) {
      final isOwner = d.idUsuarioDoa == myId;
      final isConcluded = d.status.toLowerCase().contains('conclu');
      return isOwner && isConcluded;
    }).length;

    setState(() {
      // donatedCount intencionalmente deixado nulo para não exibir
      donatedCount = null;
      availableCount = available;
      myDonationsCount = mineConcluded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = userNotifier.value;
    final userTypeLabel = user == null ? '' : (user.type.toString().split('.').last);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 238, 255, 239),
        elevation: 3,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // LOGO alinhada à esquerda
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Image.asset(
                'assets/images/logo.png',
                height: 42,
              ),
            ),

            // Nome do usuário e botão de logout à direita
            Row(
              children: [
                if (AuthService.instance.currentUser.value != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      AuthService.instance.currentUser.value!.name,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 26, 49, 27),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                IconButton(
                  tooltip: 'Sair',
                  icon: const Icon(Icons.logout, color: Color.fromARGB(255, 26, 49, 27)),
                  onPressed: () {
                    AuthService.instance.logout();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
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
              SliverToBoxAdapter(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Imagem à esquerda
                    Image.asset(
                      'assets/images/logo_apple.png',
                      width: 40, // ajuste o tamanho conforme necessário
                      height: 40,
                    ),
                    const SizedBox(width: 12), // espaço entre a imagem e o texto

                    // Textos à direita
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Bem-vindo(a)!',
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
                      ],
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 20), // ajuste o valor conforme quiser
              ),

              SliverGrid.count(
                crossAxisCount: columns,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.4,
                children: [
                  // Quero doar — sem número (count null -> não exibe)
                  _ActionCard(
                    title: 'Quero doar',
                    subtitle: 'Cadastrar alimentos para doação',
                    count: null, // não mostra número
                    icon: Icons.volunteer_activism,
                    gradient: const LinearGradient(colors: [Color(0xFF43A047), Color(0xFF66BB6A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    onTap: () async {
                      // aguarda retorno e recarrega contagens (caso a doação tenha sido criada)
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const DonateFormScreen()));
                      await _loadCounts();
                    },
                  ),

                  // Quero receber — mostra contagem em tempo real
                  _ActionCard(
                    title: 'Quero receber',
                    subtitle: 'Ver alimentos disponíveis',
                    count: availableCount,
                    icon: Icons.shopping_basket,
                    gradient: const LinearGradient(colors: [Color(0xFFFFA000), Color(0xFFFFD54F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodListScreen()));
                      await _loadCounts(); // recarrega ao voltar
                    },
                  ),

                  // Minhas doações (histórico) — mostra número do histórico (concluídos)
                  _ActionCard(
                    title: 'Minhas doações',
                    subtitle: 'Histórico de doações e recebimentos',
                    count: myDonationsCount,
                    icon: Icons.history,
                    gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF81C784)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const MyDonationsScreen()));
                      await _loadCounts();
                    },
                  ),

                  _ActionCard(
                  title: 'Meu perfil',
                  subtitle: 'Ver e editar suas informações',
                  count: null,
                  icon: Icons.person,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UserProfileScreen()),
                    );
                    setState(() {}); // Atualiza dados no dashboard após edição
                  },
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

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int? count; // agora opcional
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
          boxShadow: [BoxShadow(color: gradient.colors.last.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, size: 34, color: Colors.white)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ]),
              ),
              // se count for null, não mostramos a coluna de número
              if (count != null)
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('$count', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right, color: Colors.white70),
                ])
              else
                const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}
