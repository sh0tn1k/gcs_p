import 'package:flutter/material.dart';

import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';

import 'scale_layer_plugin_option.dart';
import 'map_layers_button.dart';
import 'map_north_button.dart';

import '../popup_menu/popup_menu.dart';
import '../mav_comm.dart';
import '../plane_data.dart';


enum MapPageType {
    plan,
    flight,
}


class MapPage extends StatefulWidget {

  final MapPageType type;

  const MapPage({required this.type, super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  int ms0 = 0;  // last planeData update timestamp

  late List<DragMarker> _dragMarkers;
  late List<Polyline> _polylines;
  final List<Marker> _planeMarkers = [];
  final popupTextStyle = TextStyle(fontSize: 12);

  @override
  void initState() {

    _dragMarkers = [
      // minimal marker example
      DragMarker(
        key: GlobalKey<DragMarkerWidgetState>(),
        point: const LatLng(56.14327329487773, 34.986173438441405),
        size: const Size.square(50),
        offset: const Offset(0, -20),
        builder: (_, __, ___) => const Icon(
          Icons.location_on,
          size: 50,
          color: Colors.green,
        ),
        onDragEnd: (details, latLng) => setState(() { }),
        onDragUpdate: (details, latLng) => setState(() { }),
      ),
      // marker with drag feedback, map scrolls when near edge
      DragMarker(
        key: GlobalKey<DragMarkerWidgetState>(),
        point: const LatLng(56.14205392095787, 35.00821046749022),
        size: const Size.square(75),
        offset: const Offset(0, -20),
        dragOffset: const Offset(0, -35),
        builder: (_, __, isDragging) {
          if (isDragging) {
            return const Icon(
              Icons.edit_location,
              size: 75,
              color: Colors.purple,
            );
          }
          return const Icon(
            Icons.location_on,
            size: 50,
            color: Colors.green,
          );
        },
        onDragStart: (details, point) => debugPrint("Start point $point"),
        onDragEnd: (details, point) => debugPrint("End point $point"),
        onTap: (point) => debugPrint("on tap"),
        onLongPress: (point) => debugPrint("on long press"),
        scrollMapNearEdge: true,
        scrollNearEdgeRatio: 2.0,
        scrollNearEdgeSpeed: 2.0,
      ),
      // marker with position information
      DragMarker(
        key: GlobalKey<DragMarkerWidgetState>(),
        point: const LatLng(56.14642914198759, 34.999198245015165),
        size: const Size(75, 50),
        builder: (_, pos, ___) {
          return Card(
            color: Colors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  pos.latitude.toStringAsFixed(3),
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  pos.longitude.toStringAsFixed(3),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
        onDragEnd: (details, latLng) => setState(() { }),
      ),
    ];


    _polylines = [
        Polyline(
          points: [_dragMarkers[0].point, _dragMarkers[1].point, _dragMarkers[2].point],
          color: Colors.red,
          strokeWidth: 2.0
        ),
    ];
    
    super.initState();
  }


  void onClickMenu(MenuItemProvider item) {
    if(item.menuUserInfo is LatLng) {
      LatLng point = item.menuUserInfo;
      mavComm.sendGpsInput(point);
      setState(() {});
    }
    
  }

  void onDismiss() {
  }

  void onShow() {
  }

  void _updatePlaneMarkers() {
    _planeMarkers.clear();
    
    //
    // Plane markers
    //

    double yaw = 0;

    // AHRS Position (Red)
    if(planeData.ahrs2 != null)
    {
      yaw = planeData.ahrs2!.yaw;

      _planeMarkers.add(
              Marker(
                point: LatLng(planeData.ahrs2!.lat / 10000000.0, planeData.ahrs2!.lng / 10000000.0),
                child:
                  Transform(
                    alignment: FractionalOffset.center,
                    transform: Matrix4.rotationZ(yaw),
                    child:
                      Image.asset("assets/imgs/redplane.png")
                  )
              )
      );
      // final lat = planeData.ahrs2!.lat / 10000000.0;
      // final lon = planeData.ahrs2!.lng / 10000000.0;
      // print("AHRS pos: $lat, $lon");
    }

    // GPS #1 Position (Blue)
    if(planeData.gpsRaw != null)
    {
      if(planeData.gpsRaw!.fixType > 0) {
        _planeMarkers.add(
              Marker(
                point: LatLng(planeData.gpsRaw!.lat / 10000000.0, planeData.gpsRaw!.lon / 10000000.0),
                child:
                  Transform(
                    alignment: FractionalOffset.center,
                    transform: Matrix4.rotationZ(yaw),
                    child:
                      Image.asset("assets/imgs/blueplane.png")
                  )
              )
        );
      }
    }

    // GPS #2 Position (Green)
    if(planeData.gps2Raw != null)
    {
      if(planeData.gps2Raw!.fixType > 0) {
        _planeMarkers.add(
              Marker(
                point: LatLng(planeData.gps2Raw!.lat / 10000000.0, planeData.gps2Raw!.lon / 10000000.0),
                child:
                  Transform(
                    alignment: FractionalOffset.center,
                    transform: Matrix4.rotationZ(yaw),
                    child:
                      Image.asset("assets/imgs/greenplane.png")
                  )
              )
        );
      }
      // final lat = planeData.gps2Raw!.lat / 10000000.0;
      // final lon = planeData.gps2Raw!.lon / 10000000.0;
      // print("GPS #2 pos: $lat, $lon");
    }
  }


  Widget _buildMap(BuildContext context) {

    if(widget.type == MapPageType.plan) {
      _dragMarkers = [];
      _polylines = [];

    }
    else if(widget.type == MapPageType.flight) {
      if(planeData.ms0 > ms0)
      {
        ms0 = planeData.ms0;
        _updatePlaneMarkers();
      }
    }

    return FlutterMap(
              options: 
                MapOptions(   // TODO Get it from settings or saved preferences
                  initialCenter: LatLng(56.142694952887425, 34.99363780617637), // TODO Initial map center
                  initialZoom: 15,

                  onTap: (tapPosition, point) {
                    final s_lat = point.latitude.toStringAsFixed(4);
                    final s_lon = point.longitude.toStringAsFixed(4);
                    PopupMenu menu = PopupMenu(
                        context: context,
                        config: MenuConfig.forList(itemWidth: 150),
                        items: [
                          // MenuItem.forList(
                          //     title: 'Copy', image: Image.asset('assets/copy.png')),
                          MenuItem.forList(
                              title: "$s_lat, $s_lon",
                              image: const Icon(Icons.copy, color: Colors.black, size: 20),
                              textStyle: popupTextStyle),
                          MenuItem.forList(
                              title: 'Set Origin',
                              image: const Icon(Icons.home, color: Colors.black, size: 20),
                              textStyle: popupTextStyle,
                              userInfo: point),
                          MenuItem.forList(
                              title: 'Power',
                              image: const Icon(Icons.power, color: Colors.black, size: 20),
                              textStyle: popupTextStyle),
                          MenuItem.forList(
                              title: 'Setting',
                              image: const Icon(Icons.settings, color: Colors.black, size: 20),
                              textStyle: popupTextStyle),
                          MenuItem.forList(
                              title: 'PopupMenu',
                              image: const Icon(Icons.menu, color: Colors.black, size: 20),
                              textStyle: popupTextStyle)
                        ],
                        onClickMenu: onClickMenu,
                        onShow: onShow,
                        onDismiss: onDismiss);
                    menu.show(rect: Rect.fromCenter(center: tapPosition.global, width: 10, height: 10));
                  },
              ),

              children: [
                TileLayer(
                  //urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  urlTemplate: 'https://mt.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
                  tileProvider: FMTC.instance('mapStore').getTileProvider(),
                ),

                const FlutterMapScaleLayer(
                  lineColor: Colors.white, //.of(context).primaryColor,
                  lineWidth: 3,
                  textStyle: TextStyle(
                                color: Colors.white, //Theme.of(context).primaryColor*/
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                  padding: EdgeInsets.all(10),
                ),

                PolylineLayer(
                  polylines: _polylines,
                ),

                DragMarkers(
                  markers: _dragMarkers,
                  alignment: Alignment.topCenter,
                ),

                MarkerLayer(
                  markers: _planeMarkers
                ),

                MapLayersButtons(
                    numberOfButtons: (widget.type == MapPageType.flight) ? 3 : 1,
                    mini: false,
                    padding: 10,
                ),
                
                //const MapNorthButton(alignment: Alignment.topRight),
              ],
    );
  }


  @override
  Widget build(BuildContext context) {
    
    return Container( 
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
        child:
          ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                _buildMap(context)
          )
    );
  }
}