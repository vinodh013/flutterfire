// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'firebase_options.dart';

/// Requires that a Firestore emulator is running locally.
/// See https://firebase.flutter.dev/docs/firestore/usage#emulator-usage
bool shouldUseFirestoreEmulator = false;

Future<Uint8List> loadBundleSetup(int number) async {
  // endpoint serves a bundle with 3 documents each containing
  // a 'number' property that increments in value 1-3.
  final url =
      Uri.https('api.rnfirebase.io', '/firestore/e2e-tests/bundle-$number');
  final response = await http.get(url);
  String string = response.body;
  return Uint8List.fromList(string.codeUnits);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  if (shouldUseFirestoreEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  runApp(App());
}

const colId = 'flutter-tests';
const docId = 'testv';
const valueId = 'v';
final firestore = FirebaseFirestore.instance;

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int id = 0;
  int value = 0;
  StreamSubscription<dynamic>? sub;

  @override
  void initState() {
    super.initState();
    subscribe();
  }

  @override
  void dispose() {
    unawaited(sub?.cancel());
    super.dispose();
  }

  void subscribe() {
    sub = firestore.collection(colId).doc(docId).snapshots().listen(
          (data) {
        setState(() {
          value = data[valueId] as int? ?? 0;
        });
      },
    );
  }

  Future<void> simulate() async {
    increment(-1);
    await firestore.disableNetwork();
    increment(1);
    await firestore.enableNetwork();
  }

  void increment(int value) {
    unawaited(asyncIncrement(value, id++));
  }

  Future<void> asyncIncrement(int value, int myId) async {
    print('[START] $myId - increment($value) ${DateTime.now()}');
    await firestore.collection(colId).doc(docId).update({
      valueId: FieldValue.increment(value),
    });
    print('[END] $myId - increment($value) ${DateTime.now()}');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Row(),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 50,
              ),
            ),
            TextButton(
              onPressed: simulate,
              child: const Text('Simulate (50% reproduction guarantee)'),
            ),
            TextButton(
              onPressed: () async {
                final simulations = <Future<void>>[];
                for (var i = 0; i < 50; i++) {
                  simulations.add(simulate());
                }
                await Future.wait(simulations);
              },
              child: const Text('Simulate (95% reproduction guarantee)'),
            ),
          ],
        ),
      ),
    );
  }
}
