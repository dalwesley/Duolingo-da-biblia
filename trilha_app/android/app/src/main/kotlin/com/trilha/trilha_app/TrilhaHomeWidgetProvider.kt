package com.trilha.trilha_app

import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews

/** Card largo (4x2): 🔥 em destaque, chamada, contagem ou "Amanhã: X" e a semana. */
class TrilhaHomeWidgetProvider : StreakWidgetProvider() {

    override val layout = R.layout.trilha_home_widget

    override fun RemoteViews.bind(
        context: Context,
        card: Card,
        data: SharedPreferences,
        now: Long,
        heightDp: Int,
    ) {
        val warm = card.counts
        // Número só quando é certo e vale algo: em "começar" seria 0 e em
        // "sumido" o widget não sabe se a sequência caiu ou se o gelo segurou.
        // Nesses dois a chamada sobe para o destaque.
        val showCount = card.state == "safe" || card.state == "risk"
        val streak = data.getString("streak_label", null) ?: "${data.getInt("streak", 0)}"
        setTextViewText(R.id.widget_streak, "🔥 ${if (showCount) streak else card.headline}")
        setTextColor(
            R.id.widget_streak,
            if (warm) 0xFFFFFFFF.toInt() else context.getColor(R.color.trilha_accent),
        )
        setTextViewText(R.id.widget_headline, card.headline)
        // Card baixo não cabe destaque + chamada + contagem + semana.
        val compact = heightDp in 1 until COMPACT_HEIGHT_DP
        setViewVisibility(
            R.id.widget_headline,
            if (showCount && !compact) View.VISIBLE else View.GONE,
        )

        if (bindTimer(card, now)) {
            setViewVisibility(R.id.widget_big, View.GONE)
        } else {
            setTextViewText(R.id.widget_big, card.big)
            setViewVisibility(R.id.widget_big, View.VISIBLE)
        }

        val labels = (data.getString("week_labels", null) ?: "S,T,Q,Q,S,S,D").split(',')
        val ink = context.getColor(if (warm) R.color.widget_warm_ink else R.color.widget_night_ink)
        week(data, now).forEachIndexed { i, mark ->
            setTextViewText(DAY_LABELS[i], labels.getOrElse(i) { "" })
            setTextColor(
                DAY_LABELS[i],
                if (mark == Mark.TODAY || mark == Mark.DONE) 0xFFFFFFFF.toInt() else 0xB3FFFFFF.toInt(),
            )
            setInt(
                DAY_DOTS[i],
                "setBackgroundResource",
                when (mark) {
                    Mark.DONE ->
                        if (warm) R.drawable.widget_dot_done_warm else R.drawable.widget_dot_done_night
                    Mark.FROZEN -> R.drawable.widget_dot_frozen
                    Mark.TODAY -> R.drawable.widget_dot_today
                    Mark.MISSED, Mark.LATER -> R.drawable.widget_dot_empty
                },
            )
            setTextViewText(DAY_DOTS[i], if (mark == Mark.DONE || mark == Mark.FROZEN) "✓" else "")
            setTextColor(
                DAY_DOTS[i],
                if (mark == Mark.FROZEN) context.getColor(R.color.widget_night_ink) else ink,
            )
        }
    }

    private companion object {
        const val COMPACT_HEIGHT_DP = 150

        val DAY_LABELS = intArrayOf(
            R.id.widget_day_label_0, R.id.widget_day_label_1, R.id.widget_day_label_2,
            R.id.widget_day_label_3, R.id.widget_day_label_4, R.id.widget_day_label_5,
            R.id.widget_day_label_6,
        )
        val DAY_DOTS = intArrayOf(
            R.id.widget_day_dot_0, R.id.widget_day_dot_1, R.id.widget_day_dot_2,
            R.id.widget_day_dot_3, R.id.widget_day_dot_4, R.id.widget_day_dot_5,
            R.id.widget_day_dot_6,
        )
    }
}
