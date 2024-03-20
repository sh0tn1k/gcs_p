import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';



class MapNorthButton extends StatelessWidget {
  final Alignment alignment;
  final IconData northIcon = Icons.navigation;

  const MapNorthButton({
    super.key,
    this.alignment = Alignment.topRight
  });

  @override
  Widget build(BuildContext context) {
    //final mapController = MapController.of(context);
    return Align(
      alignment: alignment,
      child: 
          Padding(
            padding: const EdgeInsets.only(top: 70, right: 10), // TODO Make "70" as global constant
            child:
              //Icon(northIcon, color: Theme.of(context).primaryColorDark) 
              IconButton(
                onPressed: () {
                  //final bounds = map.bounds;
                  //final centerZoom = map.getBoundsCenterZoom(bounds, options);
                  //mapController.rotate(0, source: MapEventSource.custom);
                },
                iconSize: 40,
                icon: Icon(northIcon,   // TODO Make "North Up" icon
                    color: Theme.of(context).primaryColorDark),
              ),
          ),
    );
  }
}
