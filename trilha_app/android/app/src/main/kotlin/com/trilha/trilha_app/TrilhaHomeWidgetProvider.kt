package com.trilha.trilha_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.Calendar

/**
 * Card da sequência. O app grava o estado do dia (`card_*`); aqui ele vira
 * o card e, se o app não abrir, o próprio widget vira o dia à meia-noite.
 */
class TrilhaHomeWidgetProvider : HomeWidgetProvider() {

    private data class Card(
        val state: String,
        val headline: String,
        val big: String,
        val sub: String,
        val deadline: Long,
    ) {
        val counts get() = state == "risk" || state == "start"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val streak = widgetData.getInt("streak", 0)
        val card = resolve(widgetData, System.currentTimeMillis())

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.trilha_home_widget).apply {
                val warm = card.counts
                setInt(
                    R.id.widget_root,
                    "setBackgroundResource",
                    if (warm) R.drawable.widget_card_warm else R.drawable.widget_background,
                )
                setInt(
                    R.id.widget_pill,
                    "setBackgroundResource",
                    if (warm) R.drawable.widget_pill else R.drawable.widget_pill_dim,
                )
                setTextColor(
                    R.id.widget_pill,
                    context.getColor(if (warm) R.color.widget_warm_ink else R.color.trilha_accent),
                )
                setTextViewText(R.id.widget_pill, "🔥 $streak")
                setTextViewText(R.id.widget_headline, card.headline)
                setTextViewText(R.id.widget_sub, card.sub)

                if (card.counts) {
                    val base = SystemClock.elapsedRealtime() +
                        (card.deadline - System.currentTimeMillis()).coerceAtLeast(0)
                    setChronometer(R.id.widget_timer, base, null, true)
                    setChronometerCountDown(R.id.widget_timer, true)
                    setViewVisibility(R.id.widget_timer, View.VISIBLE)
                    setViewVisibility(R.id.widget_big, View.GONE)
                } else {
                    setChronometer(R.id.widget_timer, SystemClock.elapsedRealtime(), null, false)
                    setViewVisibility(R.id.widget_timer, View.GONE)
                    setTextViewText(R.id.widget_big, card.big)
                    setViewVisibility(R.id.widget_big, View.VISIBLE)
                }

                setImageViewResource(
                    R.id.widget_anan,
                    if (card.state == "safe") R.drawable.widget_anan_sucesso
                    else R.drawable.widget_anan_triste,
                )

                val pendingIntent =
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }

        scheduleRollover(context, card.deadline)
    }

    /** Estado gravado pelo app, avançado para [now] se o dia já virou. */
    private fun resolve(data: SharedPreferences, now: Long): Card {
        val dayEnd = data.getLong("card_day_end", 0L)
        val state = data.getString("card_state", null) ?: "start"
        val headline = data.getString("card_headline", null) ?: "Stway"
        val big = data.getString("card_big", null) ?: ""
        val sub = data.getString("card_sub", null) ?: ""
        val nextMidnight = nextMidnight(now)

        if (now < dayEnd) return Card(state, headline, big, sub, dayEnd)
        if (state == "safe" && now < dayEnd + DAY_MS) {
            return Card(
                "risk",
                data.getString("card_next_headline", null) ?: headline,
                "",
                data.getString("card_next_sub", null) ?: sub,
                nextMidnight,
            )
        }
        if (state == "start") return Card(state, headline, big, sub, nextMidnight)
        return Card(
            "away",
            data.getString("card_away_headline", null) ?: headline,
            data.getString("card_away_big", null) ?: big,
            data.getString("card_away_sub", null) ?: sub,
            nextMidnight,
        )
    }

    private fun nextMidnight(now: Long): Long = Calendar.getInstance().run {
        timeInMillis = now
        add(Calendar.DAY_OF_YEAR, 1)
        set(Calendar.HOUR_OF_DAY, 0)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
        timeInMillis
    }

    /** Redesenha o card logo depois da meia-noite, com ou sem o app aberto. */
    private fun scheduleRollover(context: Context, at: Long) {
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(ComponentName(context, javaClass))
        val intent = Intent(context, javaClass).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        }
        val pending = PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val alarms = context.getSystemService(AlarmManager::class.java) ?: return
        alarms.setWindow(AlarmManager.RTC, at + 1_000, 60_000, pending)
    }

    companion object {
        private const val DAY_MS = 24L * 60 * 60 * 1000
    }
}
