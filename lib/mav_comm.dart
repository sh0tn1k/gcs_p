import 'dart:io';
import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:gcs_parodiya/dart_mavlink/mavlink.dart';
import 'package:gcs_parodiya/dart_mavlink/dialects/ardupilotmega.dart';

import 'plane_data.dart';

final mavComm = MavComm();


const kMAV_PORT = 14551;

const int kMAP_UPDATE_TMO = 250;    // update map (notifyListeners) at 4 Hz


class MavComm
{

  int ms0 = 0;

  int systemId = 0;

  late RawDatagramSocket udpSocket;
  InternetAddress? mavAddress;
  int mavPort = 0;

  Timer? gpsInputTimer;


  void findMavLink() async
  {
    for (var interface in await NetworkInterface.list()) {
        print('== Interface: ${interface.name} ==');
        for (var addr in interface.addresses) {
          mavConnect(addr.address);
          print('${addr.address} ${addr.host} ${addr.isLoopback} ${addr.rawAddress} ${addr.type.name}');
        }
    }
  }

  void mavConnect(String a) async
  {

    var dialect = MavlinkDialectArdupilotmega();
    var parser = MavlinkParser(dialect);

    parser.stream.listen((MavlinkFrame frm) {

      bool doNotify = false;

      systemId = frm.systemId;

      if(frm.message is ParamValue) {
        final msg = frm.message as ParamValue;
        planeData.requestedParams.update(
                      String.fromCharCodes(msg.paramId),
                      (value) => msg.paramValue,
                      ifAbsent: () => msg.paramValue);
        //print("Params: " + planeData.requestedParams.toString());
      }
      else if(frm.message is VfrHud) {
        planeData.vfrHud = frm.message as VfrHud;
        doNotify = true;
      }
      else if(frm.message is Ahrs2) {
        //print("AHRS2");
        planeData.ahrs2 = frm.message as Ahrs2;
        doNotify = true;
      }
      else if (frm.message is Attitude) {
        //print("ATT");
        planeData.att = frm.message as Attitude;
        doNotify = true;
      }
      else if(frm.message is GpsRawInt) {
        //print("GPS_RAW_INT");
        planeData.gpsRaw = frm.message as GpsRawInt;
        doNotify = true;
      }
      else if(frm.message is Gps2Raw) {
        //print("GPS2_RAW");
        planeData.gps2Raw = frm.message as Gps2Raw;
        doNotify = true;
      }

      int ms1 = DateTime.now().millisecondsSinceEpoch;
      if(ms1 < ms0 + kMAP_UPDATE_TMO)
      {
        doNotify = false;
      }

      if(doNotify)
      {
        //print("ms0= $ms0, ms1=$ms1, doNotify = $doNotify");
        ms0 = ms1;
        planeData.notify();
      }
    });




    print("... trying $a");

    udpSocket = await RawDatagramSocket.bind(a, kMAV_PORT);

    udpSocket.listen((e) {
        Datagram? dg = udpSocket.receive();
        if(dg != null) {
          mavAddress = dg.address;
          mavPort = dg.port;

          parser.parse(dg.data);
        }
    });

  }


  void setParam(String param_id, double value)
  {
    if(mavAddress != null) {
      final msg = ParamSet(
                      paramId: param_id.codeUnits,
                      paramValue: value,
                      paramType: mavParamTypeInt16,    // AP_Int16 airspeed_min
                      targetSystem: systemId,
                      targetComponent: 0);

      final frm = MavlinkFrame.v2(0, systemId, 0, msg);
      udpSocket.send(frm.serialize(), mavAddress!, mavPort);
    }
  }


  void getParam(String param_id)
  {
    if(mavAddress != null) {
      final msg = ParamRequestRead(
                      paramId: param_id.codeUnits,
                      paramIndex: -1,
                      targetSystem: systemId,
                      targetComponent: 0);

      final frm = MavlinkFrame.v2(0, systemId, 0, msg);
      udpSocket.send(frm.serialize(), mavAddress!, mavPort);
    }
  }


  void sendGpsInput(LatLng position)
  {
    final msg = GpsInput(
                  ignoreFlags: gpsInputIgnoreFlagHdop |
                              gpsInputIgnoreFlagVdop |
                              gpsInputIgnoreFlagHorizontalAccuracy |
                              gpsInputIgnoreFlagVerticalAccuracy |
                              gpsInputIgnoreFlagSpeedAccuracy |
                              gpsInputIgnoreFlagVelHoriz |
                              gpsInputIgnoreFlagVelVert,
                  timeUsec: 0,  // TODO
                  timeWeekMs: 0,  // TODO
                  lat: (position.latitude * 10000000).toInt(),
                  lon: (position.longitude * 10000000).toInt(),
                  alt: 1,   // TODO
                  hdop: 1,
                  vdop: 1,
                  vn: 1,
                  ve: 1,
                  vd: 1,
                  speedAccuracy: 1,
                  horizAccuracy: 1,
                  vertAccuracy: 1,
                  timeWeek: 0,
                  gpsId: 9,
                  fixType: 7,
                  satellitesVisible: 7,
                  yaw: 0);

    if(gpsInputTimer != null) {
      gpsInputTimer!.cancel();
      gpsInputTimer = null;
    }

    gpsInputTimer = Timer.periodic(
        const Duration(milliseconds: 250),
        (timer) { 
              if(mavAddress != null) {
                final frm = MavlinkFrame.v2(0, systemId, 0, msg);
                udpSocket.send(frm.serialize(), mavAddress!, mavPort);
                print("GPS_INPUT -->");
              }
        });
  }

  void stopGpsInput()
  {
    if(gpsInputTimer != null) {
      gpsInputTimer!.cancel();
      gpsInputTimer = null;
    }
  }
}
