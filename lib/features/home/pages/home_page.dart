import 'package:astral/core/services/service_manager.dart';
import 'package:astral/shared/widgets/common/home/about_home.dart';
import 'package:astral/shared/widgets/common/home/banner_carousel.dart';
import 'package:astral/shared/widgets/common/home/servers_home.dart';
import 'package:astral/shared/widgets/common/home/user_ip.dart';
import 'package:astral/shared/widgets/common/home/connect_button.dart';
import 'package:astral/shared/widgets/common/home/hitokoto_card.dart';
import 'package:astral/shared/widgets/common/home/quick_network_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:signals_flutter/signals_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    final width = MediaQuery.of(context).size.width;
    final columnCount = _getColumnCount(width);

    return Watch((context) {
      final enableBannerCarousel = ServiceManager()
          .appSettingsState
          .enableBannerCarousel
          .watch(context);

      return Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: StaggeredGrid.count(
                        crossAxisCount: columnCount,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: [
                          if (enableBannerCarousel)
                            StaggeredGridTile.fit(
                              crossAxisCellCount: columnCount,
                              child: BannerCarousel(),
                            ),
                          UserIpBox(),
                          QuickNetworkConfig(),
                          // TrafficStats(),
                          ServersHome(),
                          // UdpLog(),
                          AboutHome(),
                          HitokotoCard(),
                          // 底部空白保护，使内容能滚动得更深
                          StaggeredGridTile.fit(
                            crossAxisCellCount: columnCount,
                            child: SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom + 100,
                            ),
                          ),
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
      );
    });
  }
}
