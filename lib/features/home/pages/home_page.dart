import 'package:astral/features/home/widgets/about_home.dart';
import 'package:astral/features/home/widgets/user_ip.dart';
import 'package:astral/features/home/widgets/connect_button.dart';
import 'package:astral/features/home/widgets/hitokoto_card.dart';
import 'package:astral/features/home/widgets/quick_network_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(14, 14, 14, 14 + bottomInset),
          child: StaggeredGrid.count(
            crossAxisCount: columnCount,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              UserIpBox(),
              QuickNetworkConfig(),
              AboutHome(),
              HitokotoCard(),
              StaggeredGridTile.fit(
                crossAxisCellCount: columnCount,
                child: const SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const ConnectButton(),
    );
  }
}
