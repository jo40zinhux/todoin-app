package com.cubitapp.todoinapp

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class TodoinWidget : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val task = widgetData.getString("widget_current_task", "Abra o toDoin") ?: "Abra o toDoin"
        val streak = widgetData.getInt("widget_streak", 0)
        val xp = widgetData.getInt("widget_xp", 0)
        val isPro = widgetData.getBoolean("widget_is_pro", false)

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.todoin_widget)
            views.setTextViewText(R.id.widget_task_title, task)
            views.setTextViewText(
                R.id.widget_stats,
                if (isPro) "🔥 $streak · ⭐ $xp XP" else "toDoin Pro",
            )
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
