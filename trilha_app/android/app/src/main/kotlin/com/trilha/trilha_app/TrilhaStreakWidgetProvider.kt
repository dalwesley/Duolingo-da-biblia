package com.trilha.trilha_app

import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews

/** Selo pequeno (2x1): 🔥 com a sequência, a contagem curta e o Anan. */
class TrilhaStreakWidgetProvider : StreakWidgetProvider() {

    override val layout = R.layout.trilha_streak_widget

    override fun RemoteViews.bind(
        context: Context,
        card: Card,
        data: SharedPreferences,
        now: Long,
        heightDp: Int,
    ) {
        // Mesma regra do card largo: sem número em "começar" (0) e em "sumido"
        // (o widget não sabe se a sequência caiu).
        val showCount = card.state == "safe" || card.state == "risk"
        setTextViewText(
            R.id.widget_count,
            if (showCount) "🔥 ${data.getInt("streak", 0)}" else "🔥",
        )
        setTextColor(
            R.id.widget_count,
            if (card.counts) 0xFFFFFFFF.toInt() else context.getColor(R.color.trilha_accent),
        )
        if (bindTimer(card, now) || card.short.isEmpty()) {
            setViewVisibility(R.id.widget_short, View.GONE)
        } else {
            setTextViewText(R.id.widget_short, card.short)
            setViewVisibility(R.id.widget_short, View.VISIBLE)
        }
    }
}
