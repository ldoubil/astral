package com.kevin.astral

import android.content.Context
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent

object WidgetClickHelper {
    private const val TOGGLE_URI = "astral://toggle_connection"

    fun attachToggleIntent(context: Context, views: RemoteViews, viewId: Int) {
        val pendingIntent = HomeWidgetBackgroundIntent.getBroadcast(
            context,
            Uri.parse(TOGGLE_URI),
        )
        views.setOnClickPendingIntent(viewId, pendingIntent)
    }
}
