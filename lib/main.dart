import 'dart:io';

import 'package:dash/utils/garage_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dash/screens/screens.dart';
import 'package:dash/theme.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => GarageModel(),
      child: MaterialApp(
        title: 'Dashboard',
        home: MyApp(),
        theme: appTheme,
/*         initialRoute: '/',
        routes: {
          '/': (context) => const MyApp(),
          '/about': (context) => const AboutScreen(),
          '/newcar': (context) => const NewCarScreen(),
          '/detail': (context) => CarDetailScreen(),
          '/edit': (context) => EditCarScreen(),
        }, */
      ),
    ),
  );
  // WidgetsFlutterBinding.ensureInitialized(); // is this necessary?
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const SizedBox(
            height: 80.0,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 185, 47, 5),
              ),
              child: Text(
                'Options',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              print('settings');
            },
            // do something
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Setup Database'),
            onTap: () {
              print('dbsetup');
            },
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('IconPicker'),
            onTap: () {
              showDialog(
                  barrierColor: Colors.black.withOpacity(.5),
                  context: context,
                  builder: (BuildContext context) {
                    return IconPicker();
                  });
              /* Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => IconPicker())); */
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AboutScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.car_crash),
            title: const Text('Test'),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AboutScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    var garage = context.watch<GarageModel>(); // testing
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 185, 47, 5),
        title: const Text('Dashboard'),
      ),
      drawer: const MyDrawer(),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: (() => garage.clearCarList()),
                  // onPressed: (() => VoidCallback),
                  onLongPress: () {
                    garage.deleteAllCars();
                    // VoidCallback;
                  },
                  child: Row(
                    children: const <Widget>[
                      Icon(Icons.delete),
                      Text('Del Cars'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: (() => garage.getCars()),
                  // onPressed: (() => VoidCallback),
                  child: Row(
                    children: const <Widget>[
                      Icon(Icons.sync),
                      Text('garage'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onLongPress: (() => garage.deleteAllTxns()),
                  onPressed: (() => VoidCallback),
                  child: Row(
                    children: const <Widget>[
                      Icon(Icons.delete_forever),
                      Text('Del Txns'),
                    ],
                  ),
                ),
              ],
            ),
            const Garage(), // list of cars in garage
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const NewCarScreen()));
        },
      ),
    );
  }
}
