package com.kevin.astral

import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews

object WidgetThemeHelper {
    private const val KEY_CARD = "theme_card"
    private const val KEY_CANVAS = "theme_canvas"
    private const val KEY_TEXT_PRIMARY = "theme_text_primary"
    private const val KEY_TEXT_SECONDARY = "theme_text_secondary"
    private const val KEY_ACCENT = "theme_accent"

    private const val DEFAULT_CARD = 0xFFFFFFFF.toInt()
    private const val DEFAULT_CANVAS = 0xFFF5F5F5.toInt()
    private const val DEFAULT_TEXT_PRIMARY = 0xFF1A1A1A.toInt()
    private const val DEFAULT_TEXT_SECONDARY = 0xFF666666.toInt()
    private const val DEFAULT_ACCENT = 0xFF2196F3.toInt()

    data class Colors(
        val card: Int,
        val canvas: Int,
        val textPrimary: Int,
        val textSecondary: Int,
        val accent: Int,
    )

    fun read(prefs: SharedPreferences): Colors = Colors(
        card = readColor(prefs, KEY_CARD, DEFAULT_CARD),
        canvas = readColor(prefs, KEY_CANVAS, DEFAULT_CANVAS),
        textPrimary = readColor(prefs, KEY_TEXT_PRIMARY, DEFAULT_TEXT_PRIMARY),
        textSecondary = readColor(prefs, KEY_TEXT_SECONDARY, DEFAULT_TEXT_SECONDARY),
        accent = readColor(prefs, KEY_ACCENT, DEFAULT_ACCENT),
    )

    private fun readColor(prefs: SharedPreferences, key: String, fallback: Int): Int {
        if (!prefs.contains(key)) return fallback
        return when (val raw = prefs.all[key]) {
            is Int -> raw
            is Long -> raw.toInt()
            is String -> raw.toLongOrNull()?.toInt() ?: fallback
            else -> prefs.getInt(key, fallback)
        }
    }

    fun applySmall(context: Context, views: RemoteViews, prefs: SharedPreferences) {
        val colors = read(prefs)
        paintCard(context, views, colors)
        tintSecondary(views, colors, R.id.widget_brand)
        tintAccent(views, colors, R.id.widget_status)
    }

    fun applyMedium(context: Context, views: RemoteViews, prefs: SharedPreferences) {
        val colors = read(prefs)
        paintCard(context, views, colors)
        tintSecondary(views, colors, R.id.widget_brand)
        tintPrimary(views, colors, R.id.widget_room)
        tintSecondary(views, colors, R.id.widget_ip)
        tintAccent(views, colors, R.id.widget_status)
    }

    fun applyLarge(context: Context, views: RemoteViews, prefs: SharedPreferences) {
        val colors = read(prefs)
        paintCard(context, views, colors)
        tintSecondary(views, colors, R.id.widget_brand)
        tintPrimary(views, colors, R.id.widget_title)
        tintAccent(views, colors, R.id.widget_status)
        tintSecondary(views, colors, R.id.widget_room_label)
        tintPrimary(views, colors, R.id.widget_room)
        tintSecondary(views, colors, R.id.widget_ip_label)
        tintPrimary(views, colors, R.id.widget_ip)
        tintSecondary(views, colors, R.id.widget_duration_label)
        tintPrimary(views, colors, R.id.widget_duration)
        paintChip(context, views, R.id.widget_info_bg, colors.canvas)
    }

    private fun paintCard(context: Context, views: RemoteViews, colors: Colors) {
        views.setImageViewBitmap(
            R.id.widget_bg,
            WidgetBitmapFactory.cardBackground(context, colors.card),
        )
    }

    private fun paintChip(context: Context, views: RemoteViews, bgId: Int, color: Int) {
        views.setImageViewBitmap(
            bgId,
            WidgetBitmapFactory.chipBackground(context, color),
        )
    }

    private fun tintPrimary(views: RemoteViews, colors: Colors, viewId: Int) {
        views.setInt(viewId, "setTextColor", colors.textPrimary)
    }

    private fun tintSecondary(views: RemoteViews, colors: Colors, viewId: Int) {
        views.setInt(viewId, "setTextColor", colors.textSecondary)
    }

    private fun tintAccent(views: RemoteViews, colors: Colors, viewId: Int) {
        views.setInt(viewId, "setTextColor", colors.accent)
    }
}
