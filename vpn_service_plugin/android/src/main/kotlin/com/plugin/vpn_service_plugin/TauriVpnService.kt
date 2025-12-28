package com.plugin.vpn_service_plugin

import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import android.os.Bundle
import java.net.InetAddress
import java.util.Arrays

// VPN服务类，继承自Android系统的VpnService
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
    }

    // VPN接口文件描述符
    private lateinit var vpnInterface: ParcelFileDescriptor

    // VPN服务启动时的回调函数
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        println("vpn on start command ${intent?.getExtras()} $intent")
        var args = intent?.getExtras()

        // 创建VPN接口
        vpnInterface = createVpnInterface(args)
        println("vpn created ${vpnInterface.fd}")

        // 创建并发送启动事件数据
        val eventData = mapOf("fd" to vpnInterface.fd)
        triggerCallback("vpn_service_start", eventData)
        
        return START_STICKY
    }

    // 服务创建时的回调函数
    override fun onCreate() {
        super.onCreate()
        self = this
        println("vpn on create")
    }

    // 服务销毁时的回调函数
    override fun onDestroy() {
        println("vpn on destroy")
        super.onDestroy()
        disconnect()
        self = null
    }

    // VPN权限被撤销时的回调函数
    override fun onRevoke() {
        println("vpn on revoke")
        super.onRevoke()
        disconnect()
        self = null
    }

    // 断开VPN连接的私有方法
    private fun disconnect() {
        if (self == this && this::vpnInterface.isInitialized) {
                 // 使用空 Map 替代 JSObject
                 triggerCallback("vpn_service_stop", mapOf())
                 vpnInterface.close()
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

        // 设置MTU和DNS
        builder.setMtu(mtu)
        // builder.addDnsServer(dns)

        // 添加公共 DNS 服务器（如 Google DNS 或 114 DNS）
        // builder.addDnsServer("114.114.114.114");  // 114 DNS 
        // builder.addDnsServer("8.8.8.8");  // Google DNS 

        // // 配置路由规则，确保所有流量通过 VPN 
        // builder.addRoute("0.0.0.0",  0); // IPv4 默认路由 
        // builder.addRoute("::0", 0); // IPv6 默认路由 

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
