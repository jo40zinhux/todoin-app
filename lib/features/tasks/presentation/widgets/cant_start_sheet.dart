import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/services/analytics_service.dart';
import 'cant_start_option_tile.dart';
import 'cant_start_response_card.dart';

/// The three types of blockers a user can feel.
enum CantStartBlockerType { confused, tooBig, noEnergy }

/// Active assistant bottom sheet for when the user can't start a task.
class CantStartSheet extends StatefulWidget {
  final String? firstSubtaskTitle;
  final VoidCallback onStartTimer;

  const CantStartSheet({
    super.key,
    required this.firstSubtaskTitle,
    required this.onStartTimer,
  });

  @override
  State<CantStartSheet> createState() => _CantStartSheetState();
}

class _CantStartSheetState extends State<CantStartSheet> {
  CantStartBlockerType? _selected;

  void _selectBlocker(CantStartBlockerType type) {
    AnalyticsService.instance.cantStartUsed(blocker: type.name);
    setState(() => _selected = type);
  }

  Widget _buildSelectionScreen(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '😶 O que está te travando?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sem julgamento. Só quero te ajudar a dar o próximo passo.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        CantStartOptionTile(
          emoji: '🤔',
          label: 'Estou confuso',
          subtitle: 'Não sei por onde começar',
          onTap: () => _selectBlocker(CantStartBlockerType.confused),
        ),
        const SizedBox(height: 10),
        CantStartOptionTile(
          emoji: '😩',
          label: 'Parece muito grande',
          subtitle: 'A tarefa parece enorme demais',
          onTap: () => _selectBlocker(CantStartBlockerType.tooBig),
        ),
        const SizedBox(height: 10),
        CantStartOptionTile(
          emoji: '🪫',
          label: 'Estou sem energia',
          subtitle: 'Cansado, desmotivado ou travado',
          onTap: () => _selectBlocker(CantStartBlockerType.noEnergy),
        ),
      ],
    );
  }

  Widget _buildResponse(ThemeData theme) {
    return switch (_selected!) {
      CantStartBlockerType.confused => CantStartResponseCard(
          emoji: '🧩',
          headline: 'Vamos começar assim:',
          body: widget.firstSubtaskTitle != null
              ? '"${widget.firstSubtaskTitle}"'
              : 'Faça só o primeiro passo.\nQualquer coisa pequena conta.',
          tip: 'Só isso. Um passo de cada vez.',
          ctaLabel: 'Ok, vou tentar 💪',
          ctaColor: null,
          onCta: () => Navigator.pop(context),
        ),
      CantStartBlockerType.tooBig => CantStartResponseCard(
          emoji: '⏱️',
          headline: 'Ignore tudo.',
          body: 'Faça só por 2 minutos.\nDepois você para se quiser.',
          tip: 'Começar é a parte mais difícil. O timer ajuda.',
          ctaLabel: 'Começar agora →',
          ctaColor: theme.colorScheme.primary,
          onCta: () {
            Navigator.pop(context);
            widget.onStartTimer();
          },
        ),
      CantStartBlockerType.noEnergy => CantStartResponseCard(
          emoji: '💧',
          headline: 'Tudo bem. Cuida de você.',
          body: 'Levanta, bebe água e volta.\nVocê não precisa forçar agora.',
          tip: 'Descanso também é produtividade.',
          ctaLabel: 'Ok, volto logo 🌿',
          ctaColor: theme.colorScheme.secondary,
          onCta: () => Navigator.pop(context),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 28 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (_selected != null)
            GestureDetector(
              onTap: () => setState(() => _selected = null),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Voltar',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: const Duration(milliseconds: 200)),
            ),
          if (_selected != null) const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOut),
                ),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey(_selected),
              child: _selected == null
                  ? _buildSelectionScreen(theme)
                  : _buildResponse(theme),
            ),
          ),
        ],
      ),
    );
  }
}
