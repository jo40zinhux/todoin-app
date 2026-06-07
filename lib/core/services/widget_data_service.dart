import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Sincroniza dados para o widget da tela inicial (Pro).
/// Requer configuração nativa iOS (Widget Extension) e Android (App Widget).
abstract class WidgetDataKeys {
  static const appGroupId = 'group.com.cubitapp.todoinapp';
  static const currentTask = 'widget_current_task';
  static const streak = 'widget_streak';
  static const xp = 'widget_xp';
  static const isPro = 'widget_is_pro';
}

class WidgetDataService {
  WidgetDataService._();
  static final WidgetDataService instance = WidgetDataService._();

  bool _configured = false;

  Future<void> initialize() async {
    if (_configured) return;
    try {
      await HomeWidget.setAppGroupId(WidgetDataKeys.appGroupId);
      _configured = true;
      debugPrint('[WidgetDataService] Configurado.');
    } catch (e) {
      debugPrint('[WidgetDataService] Widget não configurado: $e');
    }
  }

  Future<void> update({
    required bool isPro,
    required String? currentTaskTitle,
    required int streak,
    required int xp,
  }) async {
    if (!_configured) return;
    if (!isPro) {
      await HomeWidget.saveWidgetData(WidgetDataKeys.isPro, false);
      return;
    }

    try {
      await HomeWidget.saveWidgetData(WidgetDataKeys.isPro, true);
      await HomeWidget.saveWidgetData(
        WidgetDataKeys.currentTask,
        currentTaskTitle ?? 'Nenhuma tarefa agora',
      );
      await HomeWidget.saveWidgetData(WidgetDataKeys.streak, streak);
      await HomeWidget.saveWidgetData(WidgetDataKeys.xp, xp);
      await HomeWidget.updateWidget(
        name: 'TodoinWidget',
        iOSName: 'TodoinWidgetExtension',
        qualifiedAndroidName: 'com.cubitapp.todoinapp.TodoinWidget',
      );
    } catch (e) {
      debugPrint('[WidgetDataService] Falha ao atualizar widget: $e');
    }
  }
}
