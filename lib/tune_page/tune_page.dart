import 'package:flutter/material.dart';

import "../mav_comm.dart";
import "../plane_data.dart";



class TunePage extends StatefulWidget {
  const TunePage({super.key});

  @override
  State<TunePage> createState() => _TunePageState();
}

class _TunePageState extends State<TunePage> {

  @override
  Widget build(BuildContext context) {

    Widget w;
    if(mavComm.gpsInputTimer != null) {
      w = ElevatedButton(
                onPressed: () { mavComm.stopGpsInput(); setState(() {});},
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Stop GPS_INPUT")
            );
    }
    else {
      w = Container();
    }
    
    return Column(
              children: [  // TODO
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => mavComm.setParam("ARSPD_FBW_MIN", 15),
                      child: const Text("Set ARSPD_FBW_MIN = 15"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed:() => mavComm.setParam("TRIM_ARSPD_CM", 2500),
                      child: const Text("Set TRIM_ARSPD_CM = 2500")
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed:() {
                        //mavComm.getParam("ARSPD_FBW_MIN");
                        //mavComm.getParam("TRIM_ARSPD_CM");
                        planeData.requestedParams.clear();
                        mavComm.getParam("ARSPD_USE");
                      },
                      child: const Text("Check Params")
                    ),
                    Expanded(child: Container()),
                    w,
                    const SizedBox(width: 10),
                  ]
                ),
                Expanded(child: Container())
              ]
    );
  }
}
