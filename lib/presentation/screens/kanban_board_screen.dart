import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meu_projeto_faculdade/theme/app_theme.dart';
import 'package:meu_projeto_faculdade/models/kanban_card_model.dart';
import 'package:meu_projeto_faculdade/providers/kanban_provider.dart';
import 'package:meu_projeto_faculdade/providers/auth_provider.dart';
import 'package:meu_projeto_faculdade/widgets/gradient_background.dart';

/// Tela do Kanban Board com drag & drop.
/// Consome dados do KanbanProvider (que por padrão usa o mock).
class KanbanBoardScreen extends StatefulWidget {
  const KanbanBoardScreen({super.key});

  @override
  State<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends State<KanbanBoardScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega os cards ao iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KanbanProvider>().loadCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Consumer<KanbanProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.neonCyan,
                        ),
                      );
                    }
                    return _buildBoard(provider);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // ─── AppBar customizada ────────────────────────────────────────
  Widget _buildAppBar() {
    final auth = context.read<AuthProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.neonCyan, AppTheme.neonPurple],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonCyan.withValues(alpha: 0.25),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(Icons.dashboard_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (b) =>
                    AppTheme.neonGradient.createShader(b),
                child: const Text(
                  'MeetSync Board',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'Olá, ${auth.user?.name ?? 'Usuário'}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Status indicator
          Consumer<KanbanProvider>(
            builder: (_, prov, __) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: prov.isRealtime
                      ? AppTheme.neonGreen.withValues(alpha: 0.15)
                      : AppTheme.neonPurple.withValues(alpha: 0.15),
                  border: Border.all(
                    color: prov.isRealtime
                        ? AppTheme.neonGreen.withValues(alpha: 0.3)
                        : AppTheme.neonPurple.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: prov.isRealtime
                            ? AppTheme.neonGreen
                            : AppTheme.neonPurple,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      prov.isRealtime ? 'Live' : 'Mock',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: prov.isRealtime
                            ? AppTheme.neonGreen
                            : AppTheme.neonPurple,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          // Tela de reuniões
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/reunioes');
            },
            icon: Icon(
              Icons.calendar_month_rounded,
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          // Logout
          IconButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed('/login');
            },
            icon: Icon(
              Icons.logout_rounded,
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Board appflowy_board ──────────────────────────────────────
  Widget _buildBoard(KanbanProvider provider) {
    return AppFlowyBoard(
      controller: provider.boardController,
      cardBuilder: (context, group, groupItem) {
        final item = groupItem as KanbanCardItem;
        return AppFlowyGroupCard(
          key: ValueKey(item.id),
          child: _buildCardTile(item.card),
        );
      },
      headerBuilder: (context, groupData) {
        return AppFlowyGroupHeader(
          title: SizedBox(
            width: 200,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _columnColor(groupData.headerData.groupId),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  groupData.headerData.groupName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        AppTheme.neonCyan.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    '${groupData.items.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.neonCyan,
                    ),
                  ),
                ),
              ],
            ),
          ),
          height: 42,
          margin: const EdgeInsets.only(bottom: 8),
        );
      },
      footerBuilder: (context, groupData) {
        return AppFlowyGroupFooter(
          height: 50,
          icon: const Icon(Icons.add, size: 18, color: AppTheme.neonCyan),
          title: const Text(
            'Novo card',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.neonCyan,
            ),
          ),
          onAddButtonClick: () =>
              _showAddCardDialog(groupData.headerData.groupId),
        );
      },
      groupConstraints: const BoxConstraints.tightFor(width: 260),
      config: AppFlowyBoardConfig(
        groupBackgroundColor: AppTheme.darkCard.withValues(alpha: 0.35),
        stretchGroupHeight: false,
      ),
    );
  }

  // ─── Card visual ───────────────────────────────────────────────
  Widget _buildCardTile(KanbanCardModel card) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.darkSurface.withValues(alpha: 0.9),
        border: Border.all(
          color: AppTheme.borderGlow.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags
          if (card.tags.isNotEmpty)
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: card.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: _tagColor(tag).withValues(alpha: 0.15),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: _tagColor(tag),
                    ),
                  ),
                );
              }).toList(),
            ),
          if (card.tags.isNotEmpty) const SizedBox(height: 8),
          // Título
          Text(
            card.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          if (card.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              card.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 8),
          // Footer: prioridade + assignee
          Row(
            children: [
              _priorityBadge(card.priority),
              const Spacer(),
              if (card.assignee != null)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor:
                          AppTheme.neonPurple.withValues(alpha: 0.3),
                      child: Text(
                        card.assignee![0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 9, color: AppTheme.neonPurple),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      card.assignee!,
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            AppTheme.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priorityBadge(int priority) {
    final labels = ['Baixa', 'Média', 'Alta'];
    final colors = [
      AppTheme.neonGreen,
      const Color(0xFFFBBF24),
      AppTheme.neonPink,
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: colors[priority].withValues(alpha: 0.12),
      ),
      child: Text(
        labels[priority],
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: colors[priority],
        ),
      ),
    );
  }

  Color _columnColor(String columnId) {
    switch (columnId) {
      case 'backlog':
        return AppTheme.textSecondary;
      case 'todo':
        return AppTheme.neonCyan;
      case 'doing':
        return const Color(0xFFFBBF24);
      case 'review':
        return AppTheme.neonPurple;
      case 'done':
        return AppTheme.neonGreen;
      default:
        return AppTheme.neonCyan;
    }
  }

  Color _tagColor(String tag) {
    final hash = tag.hashCode;
    final colors = [
      AppTheme.neonCyan,
      AppTheme.neonPurple,
      AppTheme.neonPink,
      AppTheme.neonGreen,
      const Color(0xFFFBBF24),
      const Color(0xFFFF6B6B),
    ];
    return colors[hash.abs() % colors.length];
  }

  // ─── FAB ───────────────────────────────────────────────────────
  Widget _buildFab() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonCyan.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showAddCardDialog('todo'),
        backgroundColor: AppTheme.neonCyan,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ─── Dialog: adicionar card ────────────────────────────────────
  void _showAddCardDialog(String columnId) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _columnColor(columnId),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Novo Card',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Título',
                labelStyle:
                    const TextStyle(color: AppTheme.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppTheme.borderGlow.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppTheme.neonCyan),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Descrição',
                labelStyle:
                    const TextStyle(color: AppTheme.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppTheme.borderGlow.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppTheme.neonCyan),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(
                  color: AppTheme.textSecondary.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty) {
                context.read<KanbanProvider>().addCard(
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      columnId: columnId,
                    );
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonCyan,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child:
                const Text('Criar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// Item wrapper para o AppFlowyBoard.
class KanbanCardItem extends AppFlowyGroupItem {
  final KanbanCardModel card;
  KanbanCardItem(this.card);

  @override
  String get id => card.id;
}
