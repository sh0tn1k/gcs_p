import 'package:flutter/material.dart';


const kAPP_TITLE        = 'НСУ Меркурий';
const kAPP_VERSION_NAME = 'Пародия-М';


class TitleBar extends StatefulWidget {
  const TitleBar({super.key});

  @override
  State<TitleBar> createState() => _TitleBarState();
}

class _TitleBarState extends State<TitleBar> {

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(kAPP_VERSION_NAME),
        Expanded(child: Container())
      ],
    );
  }
}