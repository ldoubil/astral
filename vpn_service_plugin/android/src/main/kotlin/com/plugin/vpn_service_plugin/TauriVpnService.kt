package com.plugin.vpn_service_plugin

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import android.os.Bundle

// VPN服务类，继承自Android系统的VpnService。
//
// 本服务仅负责建立/拆除 TUN 接口。它被系统以 BIND_VPN_SERVICE 绑定，
// 不再持有任何前台通知——连接通知由独立的 AstralKeepAliveService 负责。
// 这样进程被杀时通知能被系统立即清理，不会残留。
class TauriVpnService : VpnService() {
    companion object {
        // 用于触发回调的函数引用
        var triggerCallback: (String, Map<String, Any>) -> Unit = { _, _ -> }
        // 保存当前VPN服务实例的静态引用
        @JvmField var self: TauriVpnService? = null

        // VPN配置相关的常量
        const val IPV4_ADDR = "IPV4_ADDR"                    // IPv4地址
        const val ROUTES = "ROUTES"                          // 路由表
        const val DNS = "DNS"                                // DNS服务器
        const val DISALLOWED_APPLICATIONS = "DISALLOWED_APPLICATIONS"  // 不允许使用VPN的应用列表
        const val MTU = "MTU"                                // 最大传输单元

        const val ACTION_ESTABLISH_VPN = "com.plugin.vpn_service_plugin.ESTABLISH_VPN"
    }

    // VPN接口文件描述符
    private var vpnInterface: ParcelFileDescriptor? = null

    // 服务创建时的回调函数
    override fun onCreate() {
        super.onCreate()
        self = this
        println("vpn on create")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        println("vpn on start command ${intent?.getExtras()} $intent")
        val args = intent?.getExtras()
        try {
            val vpnInterface = createVpnInterface(args)
            this.vpnInterface = vpnInterface
            println("vpn created ${vpnInterface.fd}")
            triggerCallback("vpn_service_start", mapOf("fd" to vpnInterface.fd))
        } catch (e: Exception) {
            println("vpn establish failed: $e")
            closeVpnInterface()
            stopSelf()
        }
        return START_NOT_STICKY
    }

    // 服务销毁时的回调函数
    override fun onDestroy() {
        println("vpn on destroy")
        closeVpnInterface()
        self = null
        super.onDestroy()
    }

    // VPN权限被撤销时的回调函数
    override fun onRevoke() {
        println("vpn on revoke")
        closeVpnInterface()
        self = null
        stopSelf()
        super.onRevoke()
    }

    // 关闭VPN接口并通知Flutter
    private fun closeVpnInterface() {
        val pfd = vpnInterface
        if (pfd != null) {
            triggerCallback("vpn_service_stop", mapOf())
            try {
                pfd.close()
            } catch (_: Exception) {
            }
            vpnInterface = null
        }
    }

    // 创建VPN接口的私有方法
    private fun createVpnInterface(args: Bundle?): ParcelFileDescriptor {
        // 初始化VPN构建器
        var builder = Builder()
                .setSession("TauriVpnService")
                .setBlocking(false)

        // 获取VPN配置参数，如果未指定则使用默认值
        var mtu = args?.getInt(MTU) ?: 1500
        var ipv4Addr = args?.getString(IPV4_ADDR) ?: "100.100.100.0/24"
        var dns = args?.getString(DNS) ?: "114.114.114.114"

        // 从ipv4Addr中计算网段地址
        val ipAddrParts = ipv4Addr.split("/")
        if (ipAddrParts.size != 2) throw IllegalArgumentException("Invalid IP addr string")

        // 计算网段地址，例如从10.126.126.1/24、10.126.126.12/24等得到10.126.126.0/24
        val ipOctets = ipAddrParts[0].split(".")
        if (ipOctets.size != 4) throw IllegalArgumentException("Invalid IPv4 address format")
        val networkPrefix = "${ipOctets[0]}.${ipOctets[1]}.${ipOctets[2]}.0"
        val networkMask = ipAddrParts[1]
        val networkCidr = "$networkPrefix/$networkMask"

        // 使用计算出的网段作为路由
        var routes = arrayOf(networkCidr
        ,
            "224.0.0.0/4",  // 组播地址范围
            "255.255.255.255/32"  // 广播地址
        )
        val additionalRoutes = args?.getStringArray(ROUTES)
        if (additionalRoutes != null && additionalRoutes.isNotEmpty()) {
            routes = routes.toMutableList().apply { addAll(additionalRoutes) }.toTypedArray()
        }
        // 添加组播和广播地址到路由routes中

        var disallowedApplications = args?.getStringArray(DISALLOWED_APPLICATIONS) ?: emptyArray()

        println("vpn create vpn interface. mtu: $mtu, ipv4Addr: $ipv4Addr, networkCidr: $networkCidr, dns:" +
            "$dns, routes: ${java.util.Arrays.toString(routes)}," +
            "disallowedApplications:  ${java.util.Arrays.toString(disallowedApplications)}")

        // 设置VPN的IP地址
        builder.addAddress(ipAddrParts[0], ipAddrParts[1].toInt())

        // 设置MTU
        builder.setMtu(mtu)

        // 添加路由规则
        for (route in routes) {
            val routeParts = route.split("/")
            if (routeParts.size != 2) throw IllegalArgumentException("Invalid route cidr string")
            builder.addRoute(routeParts[0], routeParts[1].toInt())
        }

        // 添加不允许使用VPN的应用
        for (app in disallowedApplications) {
            builder.addDisallowedApplication(app)
        }

        // 在Android Q及以上版本设置非计费网络
        val vpnInterface = builder.also {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                it.setMetered(false)
            }
        }
        .establish()
        ?: throw IllegalStateException("Failed to init VpnService")

        return vpnInterface
    }
}
