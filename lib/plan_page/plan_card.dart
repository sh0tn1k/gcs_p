import 'package:flutter/material.dart';

class FplnCard extends StatefulWidget {
  const FplnCard({super.key});

  @override
  State<FplnCard> createState() => _FplnCardState();
}

class _FplnCardState extends State<FplnCard> {
  bool _expandedView = false;

  @override
  Widget build(BuildContext context) {
    const wspace10 = SizedBox(width: 10);
    const hspace10 = SizedBox(height: 10);
    const hspace2 = SizedBox(height: 2);

    Widget expandedWidget;
    if (_expandedView == true) {
      expandedWidget = Column(children: [
        Row(children: [
          Text("До высоты"),
          wspace10,
          Flexible(child: TextField()),
        ]),
        hspace2
      ]);
    } else {
      expandedWidget = Container();
    }

    return Column(children: [
      Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          border: Border.all(),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          // First line
          Row(children: [
            SizedBox(width: 30, child: Text("23")), // WP number
            wspace10,
            TextButton(onPressed: () {}, child: Text("КРУГ_ВЫС")),
            wspace10,
            IconButton(
                onPressed: () {
                  setState(() {
                    _expandedView = !_expandedView;
                  });
                },
                icon: Icon(Icons.expand_more)),
            const Spacer(),
            IconButton(onPressed: () {}, icon: Icon(Icons.delete_outline)),
          ]),
          hspace2,

          // Expanded data widget
          expandedWidget,

          // Latitude line
          Row(children: [
            SizedBox(width: 40, child: Text("Шир.")),
            wspace10,
            Flexible(child: TextField()),
            wspace10,
            IconButton(onPressed: () {}, icon: Icon(Icons.format_quote))
          ]),
          hspace2,

          // Longitude row
          Row(children: [
            SizedBox(width: 40, child: Text("Долг.")),
            wspace10,
            Flexible(child: TextField()),
            const SizedBox(width: 5),
            const Text("°"),
            wspace10,
            Flexible(child: TextField()),
            const SizedBox(width: 5),
            const Text("'"),
            wspace10,
            Flexible(child: TextField()),
            const SizedBox(width: 5),
            const Text('"'),
            wspace10,
            IconButton(onPressed: () {}, icon: Icon(Icons.format_quote))
          ]),
          hspace10
        ]),
      ),
      hspace10
    ]);
  }
}
