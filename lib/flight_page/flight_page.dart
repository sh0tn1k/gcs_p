
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



import '../mav_comm.dart';
import '../plane_data.dart';

import 'pfd_page.dart';
import 'info_bar.dart';
import '../map_page/map_page.dart';



class FlightPage extends StatefulWidget {
  const FlightPage({super.key});

  @override
  State<FlightPage> createState() => _FlightPageState();
}

class _FlightPageState extends State<FlightPage> {

  @override
  void initState()
  {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
              children: [
                //InfoBar(), // TODO Urgent ontrol buttons here
                const SizedBox(height: 10),
                Flexible(
                  child:   
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child:
                            Consumer<PlaneData>(
                              builder:(context, value, child) => PfdPage()
                            ),
                        ),
                        Flexible(
                          child:
                            Consumer<PlaneData>(
                              builder:(context, value, child) => MapPage(type: MapPageType.flight)
                            )
                        )
                      ]
                    )
                )
              ]
    );
  }
}