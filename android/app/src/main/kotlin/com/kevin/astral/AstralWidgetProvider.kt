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
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val layoutId = appWidgetManager.getAppWidgetInfo(appWidgetId)?.initialLayout
                ?: R.layout.widget_layout_small
            
            val views = RemoteViews(context.packageName, layoutId)

            val status = widgetData.getString("status_text", "未连接") ?: "未连接"
            if (layoutId == R.layout.widget_layout_small || 
                layoutId == R.layout.widget_layout_medium || 
                layoutId == R.layout.widget_layout_large) {
                views.setTextViewText(R.id.widget_status, status)
            }

            if (layoutId == R.layout.widget_layout_medium || layoutId == R.layout.widget_layout_large) {
                val ip = widgetData.getString("ip_text", "--") ?: "--"
                val room = widgetData.getString("room_name", "未选择") ?: "未选择"
                views.setTextViewText(R.id.widget_ip, if (ip == "--") "--" else "IP: $ip")
                views.setTextViewText(R.id.widget_room, room)
            }

            if (layoutId == R.layout.widget_layout_large) {
                val duration = widgetData.getString("duration_text", "00:00:00") ?: "00:00:00"
                views.setTextViewText(R.id.widget_duration, duration)
                val ip = widgetData.getString("ip_text", "--") ?: "--"
                views.setTextViewText(R.id.widget_ip, ip)
            }

            val pendingIntent = es.antonborri.home_widget.HomeWidgetBackgroundIntent.getBroadcast(
                context,
                android.net.Uri.parse("astral://toggle_connection")
            )
            views.setOnClickPendingIntent(R.id.widget_btn_toggle, pendingIntent)

            val isConnected = status == "已连接" || status == "连接中..."
            views.setTextViewText(R.id.widget_btn_toggle, if (isConnected) "断开" else "连接")

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
