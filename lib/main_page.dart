import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:window_manager/window_manager.dart';

import 'plan_page/plan_page.dart';
import 'flight_page/flight_page.dart';
import 'tune_page/tune_page.dart';

import 'plane_data.dart';


class MainPage extends StatefulWidget {

  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WindowListener {

  int _selectedIndex = 0;
  final labelType = NavigationRailLabelType.all;
  double groupAlignment = -1.0;

  @override
  void initState() {
    super.initState();

    windowManager.addListener(this);
    _init();
  }

  void _init() async {
    await windowManager.setPreventClose(true);
    setState(() { });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if(isPreventClose && context.mounted) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Are you sure you want to exit?'),
            actions: [
              ElevatedButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text('Yes'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await windowManager.destroy();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildPage() {
    switch(_selectedIndex) {
      case 0:
        return PlanPage();
      case 1:
        return Center(child: Text("Предполетная подготовка"));
      case 2:
        return FlightPage();
      case 3:
        return TunePage();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
              value: planeData,
              child:
                Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _selectedIndex,
                      groupAlignment: groupAlignment,
                      onDestinationSelected: (int index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      labelType: labelType,
                      // leading: FloatingActionButton(
                      //             elevation: 0,
                      //             onPressed: () {
                      //               // Add your onPressed code here!
                      //             },
                      //             child: const Icon(Icons.add),
                      //           ),
                      trailing: IconButton(
                                  onPressed: () {
                                    // Add your onPressed code here!
                                  },
                                  icon: const Icon(Icons.more_horiz_rounded),
                                ),

                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.route_outlined),
                          selectedIcon: Icon(Icons.route),
                          label: Text("Планирование")
                        ),
                        NavigationRailDestination(
                          //icon: Badge(child: Icon(Icons.handyman_outlined)),
                          icon: Icon(Icons.handyman_outlined),
                          selectedIcon: Icon(Icons.handyman),
                          label: Text("Подготовка")
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.flight_outlined),
                          selectedIcon: Icon(Icons.flight),
                          label: Text("Управление")
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.tune_outlined),
                          selectedIcon: Icon(Icons.tune),
                          label: Text("Настройка")
                        ),
                      ]
                    ),
                    const VerticalDivider(thickness: 1, width: 1),
                    Flexible(child: _buildPage())
                  ]
                )
    );
  }
}
