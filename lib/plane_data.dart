
import 'package:flutter/material.dart';

import 'package:gcs_parodiya/dart_mavlink/dialects/ardupilotmega.dart';


final planeData = PlaneData();


class PlaneData extends ChangeNotifier
{
  int ms0 = 0;

  VfrHud? vfrHud;
  Ahrs2? ahrs2;
  Attitude? att;
  GpsRawInt? gpsRaw;
  Gps2Raw? gps2Raw;

  Map<String, dynamic> requestedParams = {};

  void notify()
  {
    ms0 = DateTime.now().microsecondsSinceEpoch;
    notifyListeners();
  }
}

