// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';


class InfoBlock extends StatelessWidget {
  
  final int index;
  final String title;
  final String data;
  final String? units;
  
  const InfoBlock(this.index, {
    Key? key,
    required this.title,
    required this.data,
    this.units
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              
              children: [
                Text(title,
                  style: TextStyle(
                                  //color: Colors.grey.shade400,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.ideographic,
                  children: [
                    Text(data,
                      style: const TextStyle(
                                      //color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w500)
                    ),
                    Text((units != null) ? units! : "",
                      style: const TextStyle(
                                      //color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal)
                    )
                  ]
                )
              ]
    );
  }
}


class InfoBar extends StatelessWidget {

  final Alignment alignment;
  
  const InfoBar({
    super.key,
    this.alignment = Alignment.bottomLeft,
    });

  @override
  Widget build(BuildContext context) {
    //final dist = activeFpln.distanceBetween() / 1852;
    return Align(
      alignment: Alignment.topLeft,
      child:
      Padding(
        padding: const EdgeInsets.all(0),
        child:
          Container(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            //color: Colors.black.withAlpha(140),
            height: 70,
            child:
              Row(
                //crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                    InfoBlock(1, title: "GROUND SPEED", data: "---"), //appSettings.groundSpeed.toInt().toString()),
                    InfoBlock(2, title: "ALTITUDE (GPS)", data: "---"), //appSettings.gpsAltitude.toInt().toString(), units: "M"),
                    InfoBlock(5, title: "CROSS TRACK ERROR", data: "---"),
                    InfoBlock(15, title: "TRACK", data: "---"),
                    InfoBlock(20, title: "DISTANCE (DEST)", data: "---"), //dist.toInt().toString(), units: "NM"),
                    InfoBlock(7,  title: "ETA (DEST)", data: "---")                ],
            )
          )
      )
    );
  }
}
