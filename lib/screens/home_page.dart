import 'package:astral/widgets/home/about_home.dart';
import 'package:astral/widgets/home/contributors.dart'; // 添加这行
import 'package:astral/widgets/home/servers_home.dart';
import 'package:astral/widgets/home/user_ip.dart';
import 'package:astral/widgets/home/virtual_ip.dart';
import 'package:astral/widgets/home/connect_button.dart';
import 'package:astral/widgets/home/hitokoto_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // 根据宽度计算列数
  int _getColumnCount(double width) {
    if (width >= 1200) {
      return 5;
    } else if (width >= 900) {
      return 4;
    } else if (width >= 600) {
      return 3;
    }
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 需要
    final width = MediaQuery.of(context).size.width;
    final columnCount = _getColumnCount(width);
    return RepaintBoundary(
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(), // 更流畅的滚动物理效果
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: StaggeredGrid.count(
                        crossAxisCount: columnCount,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: const [
                          VirtualIpBox(),
                          UserIpBox(),
                          ServersHome(),
                          // UdpLog(),
                          AboutHome(),
                          HitokotoCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: const ConnectButton(),
      ),
    );
  }
}
