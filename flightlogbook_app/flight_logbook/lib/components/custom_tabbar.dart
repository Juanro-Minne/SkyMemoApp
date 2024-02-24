import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final TabController? tabController;

  const CustomTabBar({Key? key, this.tabController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      indicator: BoxDecoration(
        color: Colors.green.shade900, // Dark green color
        borderRadius: BorderRadius.circular(50),
      ),
      labelColor: const Color.fromARGB(255, 212, 198, 106), // Gold color
      unselectedLabelColor: Colors.white, // White color
      tabs: const [
        Tab(
          text: 'Add Flight',
        ),
        Tab(
          text: 'View Flights',
        ),
      ],
    );
  }
}


