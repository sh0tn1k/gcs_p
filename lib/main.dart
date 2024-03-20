import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:window_manager/window_manager.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'title_bar.dart';
import 'main_page.dart';
import 'mav_comm.dart';
import 'plane_data.dart';




void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  await FMTC.initialise();
  await FMTC.instance('mapStore').manage.createAsync();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  if (prefs.getBool('mapCacheReset') ?? false) {
    await FMTC.instance.rootDirectory.manage.reset();
  }

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 800),
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: kAPP_TITLE
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  mavComm.findMavLink();

  runApp(const MainApp());
}


class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAPP_TITLE,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        //colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: 
        Scaffold(
          appBar:
            AppBar(
              // TRY THIS: Try changing the color here to a specific color (to
              // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
              // change color while the other colors stay the same.
              //backgroundColor: Theme.of(context).colorScheme.primary,
              title:
                ChangeNotifierProvider.value(
                  value: planeData,
                  child: Consumer<PlaneData>(builder:(context, value, child) => TitleBar()),
                ),

              actions: <Widget>[
                IconButton(
                  onPressed: () {
                  },
                  icon: const Icon(Icons.leak_add, color: Colors.green),
                  tooltip: "Подключено",
                ),
                const SizedBox(width: 20),
                IconButton(
                  onPressed:() {
                  },
                  icon: const Icon(Icons.settings),
                  tooltip: "Настройки"
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed:() {
                  },
                  icon: const Icon(Icons.info_outline),
                  tooltip: "О программе"
                ),
                const SizedBox(width: 10)
              ]
            ),
          body:
            MainPage()
        )
    );
  }
}
