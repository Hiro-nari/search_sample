import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sample/firebase_options.dart';
import 'package:sample/search_delegate.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: InkWell(
          splashColor: Colors.white30,
          onTap: () => _search(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.search_rounded),
              Text("検索"),
            ],
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                style: const TextStyle(
                  color: Colors.black54,
                ),
                controller: TextEditingController(text: ""),
                keyboardType: TextInputType.multiline,
                maxLength: 15,
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black54,
                    ),
                  ),
                ),
                onChanged: (String value) {
                  name = value;
                },
              ),
              TextButton(
                onPressed: () async {
                  await _insertName(name);
                  name = "";
                  setState(() {});
                },
                child: const Text("名前登録"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _search(BuildContext context) async {
    await showSearch(
      context: context,
      delegate: SearchNameDelegate(),
    );
  }

  _insertName(String name) async {
    final nameOption = await _createNameOption(name);
    final FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      await db.collection("users").doc(const Uuid().v1()).set({
        "name": name,
        "nameOption": nameOption,
      });
    } catch (e) {
      print("_insertName error ${e.toString()}");
    }
  }

  Future<List<String>> _createNameOption(String value) async {
    var name = value;
    var times = <int>[];
    //分割する文字数（かつ回数）を規定（大きい数順で1文字目まで）
    for (int i = name.length; i >= 1; i--) {
      times.add(i);
    }
    var nameList = <String>[];
    for (int time in times) {
    //繰り返す回数
      for (int i = name.length; i >= 0; i--) {
        //１ずつ数字を減らしていく（１文字以上、名前の文字数以下の分割Gramが生成される）
        if (i + time <= name.length) {
           //文字数を超えて分割の後ろを指定できないので、if分で制御
          final getName = name.substring(i, i + time);
          nameList.add(getName);
          name = value;
        }
      }
    }
    return nameList;
  }
}
