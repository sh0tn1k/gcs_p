
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



import '../mav_comm.dart';
import '../plane_data.dart';

import '../map_page/map_page.dart';
import 'plan_card.dart';



class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> { 

  @override
  void initState()
  {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
              children: [
                const SizedBox(height: 10),
                //
                // Top row
                // Control buttons
                //
                Row(
                  children: [
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed:() {
                      },
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [ Icon(Icons.insert_drive_file_outlined), SizedBox(width: 5), Text("Очистить") ])
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed:() {
                      },
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [ Icon(Icons.file_open_outlined), SizedBox(width: 5), Text("Загрузить") ])
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed:() {
                      },
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [ Icon(Icons.save_outlined), SizedBox(width: 5), Text("Сохранить") ])
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed:() {
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [ Icon(Icons.file_upload_outlined), SizedBox(width: 5), Text("Установить") ]),
                    ),
                    const SizedBox(width: 10)
                  ]
                ),

                const SizedBox(height: 10),
                
                Flexible(
                  child:   
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child:
                            Consumer<PlaneData>(
                              builder:(context, value, child) => 
                                Container(
                                  width: 351,
                                  child:
                                    ListView(
                                      children: [
                                        FplnCard(),
                                        FplnCard(),
                                        FplnCard(),
                                        FplnCard(),
                                        const Divider(),
                                        const Text("Добавить точку плана полёта"),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed:() {
                                              },
                                              child: const Row(mainAxisSize: MainAxisSize.min, children: [ Icon(Icons.place_outlined), SizedBox(width: 5), Text("Координаты") ])
                                            ),
                                            const Spacer(),
                                            ElevatedButton(
                                              onPressed:() {
                                              },
                                              child: const Row(mainAxisSize: MainAxisSize.min, children: [ Icon(Icons.north_east_outlined), SizedBox(width: 5), Text("Вектор") ])
                                            ),
                                          ]
                                        ),
                                        const SizedBox(height: 10)
                                      ]
                                    )
                                )
                            ),
                        ),
                        Flexible(
                          child:
                            Consumer<PlaneData>(
                              builder:(context, value, child) => MapPage(type: MapPageType.plan)
                            )
                        )
                      ]
                    )
               )
              ]
    );
  }
}