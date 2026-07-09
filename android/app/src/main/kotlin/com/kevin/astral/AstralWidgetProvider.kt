package com.kevin.astral

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

open class AstralWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val status = widgetData.widgetString(
            "status_text",
            context.getString(R.string.widget_status_default),
        )
        val room = widgetData.widgetString(
            "room_name",
            context.getString(R.string.widget_room_default),
        )
        val ip = widgetData.widgetString(
            "ip_text",
            context.getString(R.string.widget_ip_default),
        )
        val duration = widgetData.widgetString(
            "duration_text",
            context.getString(R.string.widget_duration_default),
        )

        appWidgetIds.forEach { appWidgetId ->
            val layoutId = appWidgetManager.getAppWidgetInfo(appWidgetId)?.initialLayout
                ?: R.layout.widget_layout_small
            val views = RemoteViews(context.packageName, layoutId)

            when (layoutId) {
                R.layout.widget_layout_small -> {
                    views.setTextViewText(R.id.widget_status, status)
                    WidgetThemeHelper.applySmall(context, views, widgetData)
                }
                R.layout.widget_layout_medium -> {
                    views.setTextViewText(R.id.widget_room, room)
                    views.setTextViewText(
                        R.id.widget_ip,
                        if (ip == "--") "IP: --" else "IP: $ip",
                    )
                    views.setTextViewText(R.id.widget_status, status)
                    WidgetThemeHelper.applyMedium(context, views, widgetData)
                }
                R.layout.widget_layout_large -> {
                    views.setTextViewText(R.id.widget_status, status)
                    views.setTextViewText(R.id.widget_room, room)
                    views.setTextViewText(R.id.widget_ip, ip)
                    views.setTextViewText(R.id.widget_duration, duration)
                    WidgetThemeHelper.applyLarge(context, views, widgetData)
                }
            }

            WidgetClickHelper.attachToggleIntent(context, views, R.id.widget_root)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
