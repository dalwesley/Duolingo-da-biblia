package com.trilha.trilha_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.Calendar
import java.util.Locale

/**
 * Base dos widgets da sequência. O app grava o estado do dia (`card_*`);
 * aqui ele vira o card e, se o app não abrir, o próprio widget vira o dia
 * à meia-noite.
 */
abstract class StreakWidgetProvider : HomeWidgetProvider() {

    protected data class Card(
        val state: String,
        val headline: String,
        val big: String,
        val short: String,
        val deadline: Long,
    ) {
        val counts get() = state == "risk" || state == "start"
    }

    /** Marca de um dia na faixa da semana. */
    protected enum class Mark { DONE, FROZEN, TODAY, MISSED, LATER }

    protected abstract val layout: Int

    /** [heightDp] é a altura do widget em retrato (0 quando o launcher não informa). */
    protected abstract fun RemoteViews.bind(
        context: Context,
        card: Card,
        data: SharedPreferences,
        now: Long,
        heightDp: Int,
    )

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val now = System.currentTimeMillis()
        val card = resolve(widgetData, now)

        appWidgetIds.forEach { widgetId ->
            val heightDp = appWidgetManager.getAppWidgetOptions(widgetId)
                .getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT)
            val views = RemoteViews(context.packageName, layout).apply {
                setInt(
                    R.id.widget_root,
                    "setBackgroundResource",
                    if (card.counts) R.drawable.widget_card_warm else R.drawable.widget_background,
                )
                setImageViewResource(
                    R.id.widget_anan,
                    if (card.state == "safe") R.drawable.widget_anan_sucesso
                    else R.drawable.widget_anan_triste,
                )
                bind(context, card, widgetData, now, heightDp)

                val pendingIntent =
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }

        scheduleRollover(context, card.deadline)
    }

    /** Redimensionado: redesenha para a nova altura. */
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId), HomeWidgetPlugin.getData(context))
    }

    /** Contagem até a meia-noite quando a sequência está em jogo; devolve se mostrou. */
    protected fun RemoteViews.bindTimer(card: Card, now: Long): Boolean {
        if (card.counts) {
            val base = SystemClock.elapsedRealtime() + (card.deadline - now).coerceAtLeast(0)
            setChronometer(R.id.widget_timer, base, null, true)
            setChronometerCountDown(R.id.widget_timer, true)
            setViewVisibility(R.id.widget_timer, View.VISIBLE)
        } else {
            setChronometer(R.id.widget_timer, SystemClock.elapsedRealtime(), null, false)
            setViewVisibility(R.id.widget_timer, View.GONE)
        }
        return card.counts
    }

    /** Segunda a domingo da semana de [now]. */
    protected fun week(data: SharedPreferences, now: Long): List<Mark> {
        val played = data.getString("played_days", null).orEmpty().split(',').toSet()
        val frozen = data.getString("frozen_days", null).orEmpty().split(',').toSet()
        val cal = Calendar.getInstance().apply { timeInMillis = now }
        val today = dayKey(cal)
        cal.add(Calendar.DAY_OF_YEAR, -((cal.get(Calendar.DAY_OF_WEEK) + 5) % 7))
        return List(7) {
            val key = dayKey(cal)
            cal.add(Calendar.DAY_OF_YEAR, 1)
            when {
                key in played -> Mark.DONE
                key in frozen -> Mark.FROZEN
                key == today -> Mark.TODAY
                key < today -> Mark.MISSED
                else -> Mark.LATER
            }
        }
    }

    /** Estado gravado pelo app, avançado para [now] se o dia já virou. */
    private fun resolve(data: SharedPreferences, now: Long): Card {
        val dayEnd = data.getLong("card_day_end", 0L)
        val state = data.getString("card_state", null) ?: "start"
        val headline = data.getString("card_headline", null) ?: "Stway"
        val big = data.getString("card_big", null) ?: ""
        val short = data.getString("card_short", null) ?: ""
        val nextMidnight = nextMidnight(now)

        if (now < dayEnd) return Card(state, headline, big, short, dayEnd)
        if (state == "safe" && now < dayEnd + DAY_MS) {
            return Card(
                "risk",
                data.getString("card_next_headline", null) ?: headline,
                "",
                "",
                nextMidnight,
            )
        }
        if (state == "start") return Card(state, headline, big, short, nextMidnight)
        return Card(
            "away",
            data.getString("card_away_headline", null) ?: headline,
            data.getString("card_away_big", null) ?: big,
            data.getString("card_away_short", null) ?: short,
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

    private fun dayKey(cal: Calendar): String = String.format(
        Locale.US,
        "%04d-%02d-%02d",
        cal.get(Calendar.YEAR),
        cal.get(Calendar.MONTH) + 1,
        cal.get(Calendar.DAY_OF_MONTH),
    )

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
