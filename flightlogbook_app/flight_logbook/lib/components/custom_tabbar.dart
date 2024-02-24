import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final TabController? tabController;
  final List<Widget> children;

  const CustomTabBar({
    Key? key,
    this.tabController,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      unselectedLabelColor: Colors.black,
      tabs: children,
    );
  }
}
