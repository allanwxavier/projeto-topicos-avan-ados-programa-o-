import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meu_projeto_faculdade/providers/auth_provider.dart';
import 'package:meu_projeto_faculdade/widgets/gradient_background.dart';
import 'package:meu_projeto_faculdade/services/glass_card.dart';
import 'package:meu_projeto_faculdade/widgets/futuristic_text_field.dart';
import 'package:meu_projeto_faculdade/widgets/neon_button.dart';
import 'package:meu_projeto_faculdade/theme/app_theme.dart';
import 'package:meu_projeto_faculdade/presentation/screens/kanban_board_screen.dart';

/// Tela de Login Futurista.
/// Utiliza GradientBackground, GlassCard, FuturisticTextField e NeonButton
/// conforme definido no plano de desenvolvimento.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _matriculaController = TextEditingController();
  final _cargoController = TextEditingController();
  final _setorController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLogin = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _matriculaController.dispose();
    _cargoController.dispose();
    _setorController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    bool success;

    if (_isLogin) {
      success = await auth.login(
        _nameController.text,
        _passwordController.text,
      );
    } else {
      success = await auth.register(
        _nameController.text,
        _passwordController.text,
        _matriculaController.text,
        _cargoController.text,
        _setorController.text,
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const KanbanBoardScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ─── Logo / Ícone ──────────────────
                      _buildLogo(),
                      const SizedBox(height: 16),
                      // ─── Título ────────────────────────
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.neonGradient.createShader(bounds),
                        child: const Text(
                          'MeetSync',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Gerencie seus projetos em tempo real',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary.withValues(alpha: 0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // ─── Card de Login ─────────────────
                      GlassCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _isLogin ? 'Entrar' : 'Criar Conta',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isLogin = !_isLogin;
                                      });
                                    },
                                    child: Text(
                                      _isLogin ? 'Criar Conta' : 'Fazer Login',
                                      style: const TextStyle(
                                        color: AppTheme.neonCyan,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _isLogin
                                    ? 'Acesse sua conta para continuar'
                                    : 'Preencha os dados para se cadastrar',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 28),
                              FuturisticTextField(
                                label: _isLogin ? 'Usuário' : 'Nome Completo',
                                hintText: _isLogin ? 'Seu nome de acesso' : 'Seu nome completo',
                                controller: _nameController,
                                prefixIcon: Icons.person_outline_rounded,
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Informe seu nome'
                                        : null,
                              ),
                              if (!_isLogin) ...[
                                const SizedBox(height: 18),
                                FuturisticTextField(
                                  label: 'Matrícula',
                                  hintText: '1 a 6 dígitos numéricos',
                                  controller: _matriculaController,
                                  prefixIcon: Icons.badge_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Informe sua matrícula';
                                    }
                                    if (v.length > 6 || int.tryParse(v) == null) {
                                      return 'Matrícula inválida (máx 6 dígitos)';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),
                                FuturisticTextField(
                                  label: 'Cargo',
                                  hintText: 'Seu cargo na empresa',
                                  controller: _cargoController,
                                  prefixIcon: Icons.work_outline_rounded,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Informe seu cargo'
                                          : null,
                                ),
                                const SizedBox(height: 18),
                                FuturisticTextField(
                                  label: 'Setor',
                                  hintText: 'Seu setor de atuação',
                                  controller: _setorController,
                                  prefixIcon: Icons.business_center_outlined,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Informe seu setor'
                                          : null,
                                ),
                              ],
                              const SizedBox(height: 18),
                              FuturisticTextField(
                                label: 'Senha',
                                hintText: '••••••••',
                                controller: _passwordController,
                                prefixIcon: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: AppTheme.textSecondary,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Informe sua senha'
                                        : null,
                              ),
                              const SizedBox(height: 10),
                              // ─── Mensagem de erro ──────
                              Consumer<AuthProvider>(
                                builder: (_, auth, __) {
                                  if (auth.errorMessage == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(top: 8, bottom: 4),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline_rounded,
                                          color: AppTheme.neonPink,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            auth.errorMessage!,
                                            style: const TextStyle(
                                              color: AppTheme.neonPink,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              // ─── Botão Login ──────────
                              Consumer<AuthProvider>(
                                builder: (_, auth, __) {
                                  return NeonButton(
                                    text: _isLogin ? 'ACESSAR' : 'CADASTRAR',
                                    icon: _isLogin ? Icons.arrow_forward_rounded : Icons.person_add_rounded,
                                    isLoading: auth.isLoading,
                                    onPressed:
                                        auth.isLoading ? null : _handleSubmit,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // ─── Dica de login mock ───────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppTheme.neonPurple.withValues(alpha: 0.08),
                          border: Border.all(
                            color:
                                AppTheme.neonPurple.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color:
                                  AppTheme.neonPurple.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Mock: qualquer nome + senha 1234',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.neonPurple
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppTheme.neonCyan.withValues(alpha: 0.2),
            AppTheme.neonCyan.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppTheme.neonCyan, AppTheme.neonPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonCyan.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.dashboard_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
