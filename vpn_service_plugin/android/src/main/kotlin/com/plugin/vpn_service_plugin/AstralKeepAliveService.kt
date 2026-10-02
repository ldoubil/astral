package com.plugin.vpn_service_plugin

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build

// 独立保活服务。
//
// 与 TauriVpnService（系统 VPN 绑定服务）分离：
// 本服务是一个普通的“已启动前台服务”，不被系统以 BIND_VPN_SERVICE 绑定，
// 因此当进程被杀时，系统会立即清理本服务及其通知。
//
// 之前通知残留的根因是：连接通知直接挂在被系统 VPN 绑定的 VpnService 上，
// tun0 拆除时系统对死进程执行 unbind 会抛异常，从而中断服务清理。
class AstralKeepAliveService : Service() {
    companion object {
        const val CHANNEL_ID = "astral_connection"
        const val NOTIFICATION_ID = 1001

        const val ACTION_START = "com.plugin.vpn_service_plugin.KEEPALIVE_START"
        const val ACTION_STOP = "com.plugin.vpn_service_plugin.KEEPALIVE_STOP"
        const val EXTRA_STATUS = "status"
        const val EXTRA_IP = "ip"
        const val EXTRA_DURATION = "duration"
        const val EXTRA_SHOW_CONTENT = "show_content"

        @JvmField var instance: AstralKeepAliveService? = null
    }

    private var showContent = true

    override fun onCreate() {
        super.onCreate()
        instance = this
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopMe()
            return START_NOT_STICKY
        }

        showContent = intent?.getBooleanExtra(EXTRA_SHOW_CONTENT, true) ?: true
        val status = intent?.getStringExtra(EXTRA_STATUS) ?: "连接中"
        val ip = intent?.getStringExtra(EXTRA_IP) ?: "正在获取..."
        val duration = intent?.getStringExtra(EXTRA_DURATION) ?: "00:00"

        promote(status, ip, duration)
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): android.os.IBinder? = null

    // 更新通知内容（已连接后每秒刷新时长/IP）
    fun update(status: String, ip: String, duration: String) {
        showContent = true
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(NOTIFICATION_ID, buildNotification(status, ip, duration, true))
    }

    // 隐藏通知内容（用户在设置中关闭连接通知）。
    // 注意：作为前台服务无法完全隐藏通知本身，这里展示一条无内容的最小通知。
    fun hideContent() {
        showContent = false
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(NOTIFICATION_ID, buildNotification("", "", "", false))
    }

    // 重新展示完整内容
    fun showContentAgain(status: String, ip: String, duration: String) {
        showContent = true
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(NOTIFICATION_ID, buildNotification(status, ip, duration, true))
    }

    private fun promote(status: String, ip: String, duration: String) {
        val notification = buildNotification(status, ip, duration, showContent)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun stopMe() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.cancel(NOTIFICATION_ID)
        instance = null
        stopSelf()
    }

    override fun onDestroy() {
        instance = null
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Astral 连接状态",
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = "显示 Astral 连接状态和信息"
                setShowBadge(false)
            }
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(status: String, ip: String, duration: String, withContent: Boolean): Notification {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = launchIntent?.let {
            PendingIntent.getActivity(
                this,
                0,
                it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        builder
            .setSmallIcon(applicationInfo.icon)
            .setOngoing(true)
            .setAutoCancel(false)
            .setOnlyAlertOnce(true)
            .setContentIntent(pendingIntent)

        if (withContent) {
            val title = if (status == "已连接" || status.startsWith("已连接")) {
                "Astral - 已连接"
            } else {
                "Astral - $status"
            }
            builder.setContentTitle(title)
            if (ip.isNotEmpty()) {
                builder.setContentText("IP: $ip | 连接时间: $duration")
            }
        } else {
            builder.setContentTitle("Astral")
        }

        return builder.build()
    }
}
