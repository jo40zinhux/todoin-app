import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// The three types of blockers a user can feel.
enum _BlockerType { confused, tooBig, noEnergy }

/// Active assistant bottom sheet for when the user can't start a task.
///
/// Shows a friendly "What's blocking you?" selection, then transitions
/// to a tailored ADHD-friendly response with a clear next action.
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   backgroundColor: Colors.transparent,
///   builder: (_) => CantStartSheet(
///     firstSubtaskTitle: task.firstIncompleteSub?.title,
///     onStartTimer: _openTimer,
///   ),
/// );
/// ```
class CantStartSheet extends StatefulWidget {
  /// Title of the first incomplete subtask (shown in the "Confused" response).
  final String? firstSubtaskTitle;

  /// Called when the user chooses "Começar agora" from the "Too big" response.
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
  _BlockerType? _selected;

  // ── Selection screen ──────────────────────────────────────────────────────

  Widget _buildSelectionScreen(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '😶 O que está te travando?',
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Sem julgamento. Só quero te ajudar a dar o próximo passo.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 24),
        _optionTile(
          theme,
          emoji: '🤔',
          label: 'Estou confuso',
          subtitle: 'Não sei por onde começar',
          type: _BlockerType.confused,
        ),
        const SizedBox(height: 10),
        _optionTile(
          theme,
          emoji: '😩',
          label: 'Parece muito grande',
          subtitle: 'A tarefa parece enorme demais',
          type: _BlockerType.tooBig,
        ),
        const SizedBox(height: 10),
        _optionTile(
          theme,
          emoji: '🪫',
          label: 'Estou sem energia',
          subtitle: 'Cansado, desmotivado ou travado',
          type: _BlockerType.noEnergy,
        ),
      ],
    );
  }

  Widget _optionTile(
    ThemeData theme, {
    required String emoji,
    required String label,
    required String subtitle,
    required _BlockerType type,
  }) {
    final colorScheme = theme.colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _selected = type),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600)),
                    Text(subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideX(begin: 0.06, end: 0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  // ── Response screens ──────────────────────────────────────────────────────

  Widget _buildResponse(ThemeData theme) {
    return switch (_selected!) {
      _BlockerType.confused => _ResponseCard(
          theme: theme,
          emoji: '🧩',
          headline: 'Vamos começar assim:',
          body: widget.firstSubtaskTitle != null
              ? '"${widget.firstSubtaskTitle}"'
              : 'Faça só o primeiro passo.\nQualquer coisa pequena conta.',
          tip: 'Só isso. Um passo de cada vez.',
          ctaLabel: 'Ok, vou tentar 💪',
          ctaColor: null, // uses primary
          onCta: () => Navigator.pop(context),
        ),
      _BlockerType.tooBig => _ResponseCard(
          theme: theme,
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
      _BlockerType.noEnergy => _ResponseCard(
          theme: theme,
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

  // ── Build ─────────────────────────────────────────────────────────────────

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
          // Drag handle
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

          // Back arrow when a response is shown
          if (_selected != null)
            GestureDetector(
              onTap: () => setState(() => _selected = null),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios_new_rounded,
                      size: 14, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('Voltar',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 200)),
            ),

          if (_selected != null) const SizedBox(height: 16),

          // Animated switcher for selection ↔ response
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: anim,
                  curve: Curves.easeOut,
                )),
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

// ─────────────────────────────────────────────────────────────────────────────
// Shared response card layout
// ─────────────────────────────────────────────────────────────────────────────

class _ResponseCard extends StatelessWidget {
  final ThemeData theme;
  final String emoji;
  final String headline;
  final String body;
  final String tip;
  final String ctaLabel;
  final Color? ctaColor;
  final VoidCallback onCta;

  const _ResponseCard({
    required this.theme,
    required this.emoji,
    required this.headline,
    required this.body,
    required this.tip,
    required this.ctaLabel,
    required this.ctaColor,
    required this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Emoji
        Text(emoji, style: const TextStyle(fontSize: 48))
            .animate()
            .scale(
              begin: const Offset(0.6, 0.6),
              end: const Offset(1.0, 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
            ),
        const SizedBox(height: 12),

        // Headline
        Text(
          headline,
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),

        // Body
        Text(
          body,
          style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant, height: 1.6),
        ),
        const SizedBox(height: 16),

        // Tip chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  size: 16, color: colorScheme.tertiary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  tip,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // CTA button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton(
            onPressed: onCta,
            style: FilledButton.styleFrom(
              backgroundColor: ctaColor ?? colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              ctaLabel,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        )
            .animate()
            .fadeIn(
              delay: const Duration(milliseconds: 150),
              duration: const Duration(milliseconds: 300),
            )
            .slideY(
              begin: 0.15,
              end: 0,
              delay: const Duration(milliseconds: 150),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            ),
      ],
    );
  }
}
