package com.trilha.trilha_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class TrilhaHomeWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val streak = widgetData.getInt("streak", 0)
        val goal = widgetData.getInt("daily_goal", 1).coerceAtLeast(1)
        val done = widgetData.getInt("missions_done", 0).coerceAtLeast(0)
        val goalMet = widgetData.getBoolean("goal_met", false)
        val atRisk = widgetData.getBoolean("streak_at_risk", false)
        val statusLine = widgetData.getString("status_line", "Abra o Stway")
        val streakLabel = widgetData.getString("streak_label", "0 dias")
        val progressLabel = widgetData.getString("progress_label", "0/$goal missões")

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.trilha_home_widget).apply {
                setTextViewText(R.id.widget_brand, "STWAY")
                setTextViewText(R.id.widget_streak_value, streak.toString())
                setTextViewText(R.id.widget_streak_label, streakLabel)
                setTextViewText(R.id.widget_progress_label, progressLabel)
                setTextViewText(R.id.widget_status, statusLine)

                setProgressBar(
                    R.id.widget_progress,
                    goal,
                    done.coerceAtMost(goal),
                    false,
                )

                setViewVisibility(
                    R.id.widget_risk_badge,
                    if (atRisk && !goalMet) View.VISIBLE else View.GONE,
                )

                val statusColor = when {
                    goalMet -> R.color.trilha_accent
                    atRisk -> R.color.trilha_streak
                    else -> R.color.trilha_text_muted
                }
                setTextColor(R.id.widget_status, context.getColor(statusColor))

                val pendingIntent =
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
