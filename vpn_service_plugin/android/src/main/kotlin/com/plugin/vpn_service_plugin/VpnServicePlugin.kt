package com.plugin.vpn_service_plugin

import android.app.Activity
import android.content.Intent
import android.net.VpnService
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel

// VPN服务插件类，实现Flutter插件、方法调用处理和Activity感知接口
class VpnServicePlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
    // 方法通道，用于Flutter和原生代码通信
    private lateinit var channel : MethodChannel
    // 事件通道，用于向Flutter发送VPN状态变化事件
    private lateinit var eventChannel: EventChannel
    // Activity实例，用于启动VPN服务
    private lateinit var activity: Activity
    // 事件接收器
    private var eventSink: EventChannel.EventSink? = null

    // 插件附加到Flutter引擎时调用
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "vpn_service")
        channel.setMethodCallHandler(this)

        // 初始化事件通道
        eventChannel = EventChannel(binding.binaryMessenger, "vpn_service_events")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                // 设置VPN服务的回调函数
                TauriVpnService.triggerCallback = { event, data ->
                    eventSink?.success(mapOf("event" to event, "data" to data))
                }
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    // 处理来自Flutter的方法调用
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            // 准备VPN服务
            "prepareVpn" -> {
                val intent = VpnService.prepare(activity)
                if (intent != null) {
                    // 需要用户授权，启动授权界面
                    activity.startActivityForResult(intent, 0x0f)
                    result.success(mapOf("errorMsg" to "again"))
                } else {
                    // 已经获得授权
                    result.success(mapOf<String, Any>())
                }
            }
            // 启动VPN服务（仅建立TUN；通知由保活服务负责）
            "startVpn" -> {
                val args = call.arguments<Map<String, Any>>()

                val intent = VpnService.prepare(activity)
                if (intent != null) {
                    // 需要先获取VPN权限
                    result.success(mapOf("errorMsg" to "need_prepare"))
                } else {
                    // 配置并启动VPN服务
                    val serviceIntent = Intent(activity, TauriVpnService::class.java)

                    // 处理IPv4地址
                    serviceIntent.putExtra("IPV4_ADDR", args?.get("ipv4Addr") as? String)

                    // 处理路由列表 - 从List<Dynamic>转换为Array<String>
                    val routesList = args?.get("routes") as? List<*>
                    if (routesList != null) {
                        val routesArray = routesList.filterIsInstance<String>().toTypedArray()
                        serviceIntent.putExtra("ROUTES", routesArray)
                    }

                    // 处理DNS
                    serviceIntent.putExtra("DNS", args?.get("dns") as? String)

                    // 处理不允许的应用列表
                    val disallowedAppsList = args?.get("disallowedApplications") as? List<*>
                    if (disallowedAppsList != null) {
                        val disallowedAppsArray = disallowedAppsList.filterIsInstance<String>().toTypedArray()
                        serviceIntent.putExtra("DISALLOWED_APPLICATIONS", disallowedAppsArray)
                    }

                    // 处理MTU
                    val mtu = args?.get("mtu")
                    if (mtu is Int) {
                        serviceIntent.putExtra("MTU", mtu)
                    }

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        activity.startForegroundService(serviceIntent)
                    } else {
                        activity.startService(serviceIntent)
                    }
                    result.success(mapOf<String, Any>())
                }
            }
            // 停止VPN服务
            "stopVpn" -> {
                TauriVpnService.self?.onRevoke()
                activity.stopService(Intent(activity, TauriVpnService::class.java))
                // 同时停止保活服务，移除连接通知
                stopKeepAlive()
                result.success(mapOf<String, Any>())
            }
            // 启动保活服务（连接中阶段）
            "startForeground" -> {
                val enabled = (call.arguments<Map<String, Any>>()?.get("notificationsEnabled") as? Boolean) ?: true
                startKeepAlive(
                    status = "连接中",
                    ip = "正在获取...",
                    duration = "00:00",
                    showContent = enabled,
                )
                result.success(mapOf<String, Any>())
            }
            // 更新连接通知内容
            "updateNotification" -> {
                val args = call.arguments<Map<String, Any>>()
                AstralKeepAliveService.instance?.update(
                    (args?.get("status") as? String) ?: "",
                    (args?.get("ip") as? String) ?: "",
                    (args?.get("duration") as? String) ?: "",
                )
                result.success(mapOf<String, Any>())
            }
            // 移除连接通知内容（设置中关闭）
            "removeNotification" -> {
                AstralKeepAliveService.instance?.hideContent()
                result.success(mapOf<String, Any>())
            }
            // 重新显示连接通知（设置中开启）
            "showNotification" -> {
                val args = call.arguments<Map<String, Any>>()
                AstralKeepAliveService.instance?.showContentAgain(
                    (args?.get("status") as? String) ?: "已连接",
                    (args?.get("ip") as? String) ?: "",
                    (args?.get("duration") as? String) ?: "00:00",
                )
                result.success(mapOf<String, Any>())
            }
            else -> result.notImplemented()
        }
    }

    private fun startKeepAlive(
        status: String,
        ip: String,
        duration: String,
        showContent: Boolean,
    ) {
        val intent = Intent(activity, AstralKeepAliveService::class.java).apply {
            action = AstralKeepAliveService.ACTION_START
            putExtra(AstralKeepAliveService.EXTRA_STATUS, status)
            putExtra(AstralKeepAliveService.EXTRA_IP, ip)
            putExtra(AstralKeepAliveService.EXTRA_DURATION, duration)
            putExtra(AstralKeepAliveService.EXTRA_SHOW_CONTENT, showContent)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            activity.startForegroundService(intent)
        } else {
            activity.startService(intent)
        }
    }

    private fun stopKeepAlive() {
        val intent = Intent(activity, AstralKeepAliveService::class.java).apply {
            action = AstralKeepAliveService.ACTION_STOP
        }
        activity.startService(intent)
    }

    // 插件从Flutter引擎分离时调用
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    // 插件附加到Activity时调用
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    // Activity生命周期相关回调
    override fun onDetachedFromActivity() {}
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }
    override fun onDetachedFromActivityForConfigChanges() {}
}
