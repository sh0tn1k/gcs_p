import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../plane_data.dart';


class MapLayersButtons extends StatelessWidget {

  final int numberOfButtons;
  final bool mini;
  final Alignment alignment;
  final double padding;
  final Color? color;
  
  const MapLayersButtons({
    super.key,
    this.numberOfButtons = 3,
    this.mini = false,
    this.alignment = Alignment.bottomLeft,
    this.padding = 2.0,
    this.color,
    });

  List<Widget> _buildButtonsList(BuildContext context) {
    final List<Widget> _buttons = [];
    const radius15 = Radius.circular(15);

    if(numberOfButtons == 1) {
      _buttons.add(
        FloatingActionButton(
          heroTag: 'layersButton',
          mini: mini,
          backgroundColor: color ?? Theme.of(context).primaryColor,
          shape: const RoundedRectangleBorder(
                          borderRadius:
                            BorderRadius.only(
                              topLeft: radius15,
                              bottomLeft: radius15,
                              topRight: Radius.zero,
                              bottomRight: Radius.zero
                            )
                        ),
          child: const Icon(
                  Icons.layers_outlined,
                  color: Colors.white,
                  size: 30.0,
                ),
          onPressed: () {},
          )
      );

      _buttons.add(
          FloatingActionButton(
              heroTag: 'locButton',
              mini: mini,
              backgroundColor: color ?? Theme.of(context).primaryColor,
              shape: const RoundedRectangleBorder(
                              borderRadius:
                                BorderRadius.only(
                                  topLeft: Radius.zero,
                                  bottomLeft: Radius.zero,
                                  topRight: radius15,
                                  bottomRight: radius15
                                )
                            ),
              child: const Icon(
                    Icons.my_location_outlined,
                    color: Colors.white,
                    size: 30.0,
              ),
              onPressed: () { // TODO Go to my location
              },
          )
      );

    }
    else if(numberOfButtons > 1) {
      _buttons.add(
        FloatingActionButton(
          heroTag: 'layersButton',
          mini: mini,
          backgroundColor: color ?? Theme.of(context).primaryColor,
          shape: const RoundedRectangleBorder(
                          borderRadius:
                            BorderRadius.only(
                              topLeft: radius15,
                              bottomLeft: radius15,
                              topRight: Radius.zero,
                              bottomRight: Radius.zero
                            )
                        ),
          child: const Icon(
                  Icons.layers_outlined,
                  color: Colors.white,
                  size: 30.0,
                ),
          onPressed: () {},
          )
      );

      _buttons.add(
          FloatingActionButton(
              heroTag: 'fplnButton',
              mini: mini,
              backgroundColor: color ?? Theme.of(context).primaryColor,
              shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.zero)
                            ),
              child: const Icon(
                    Icons.route_outlined,
                    color: Colors.white,
                    size: 30.0,
              ),
              onPressed: () {},
          )
      );

      _buttons.add(
          FloatingActionButton(
              heroTag: 'acButton',
              mini: mini,
              backgroundColor: color ?? Theme.of(context).primaryColor,
              shape: const RoundedRectangleBorder(
                              borderRadius:
                                BorderRadius.only(
                                  topLeft: Radius.zero,
                                  bottomLeft: Radius.zero,
                                  topRight: radius15,
                                  bottomRight: radius15
                                )
                            ),
              child: const Icon(
                    Icons.near_me_outlined,
                    color: Colors.white,
                    size: 30.0,
              ),
              onPressed: () {
                if(planeData.ahrs2 != null) {
                  final mapController = MapController.of(context);
                  mapController.move(
                      LatLng(
                          planeData.ahrs2!.lat / 10000000.0,
                          planeData.ahrs2!.lng / 10000000.0),
                      mapController.camera.zoom);
                }
              }, // TODO Go to airplane location
          )
      );
    }

    return _buttons;
  }

  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: alignment,
      child:
      Padding(
        padding:
          EdgeInsets.all(padding),
        child:
          Row(
              //crossAxisAlignment: CrossAxisAlignment.center,
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children:
                _buildButtonsList(context)
          ),
      )
    );
  }
}