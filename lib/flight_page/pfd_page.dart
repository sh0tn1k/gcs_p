import 'package:flutter/material.dart';

import 'indicators/ati_rus.dart';


class PfdPage extends StatefulWidget {
  const PfdPage({super.key});

  @override
  State<PfdPage> createState() => _PfdPageState();
}

class _PfdPageState extends State<PfdPage> {

  @override
  Widget build(BuildContext context) {

    return Column(
              children: [
                AttitudeIndicatorRus(height: 300),
                Flexible(child: Container())
              ],
    );
  }
}