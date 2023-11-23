import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _oromic = TextEditingController();
  final _english = TextEditingController();

  final _mybox = Hive.box('mybox');
  void write() {
    _mybox.put(1, 'first');
  }

  void read() {
    final data = _mybox.keys.map((key) {
      final item = _mybox.get(key);
      return {"key": key, "oromic": item["oromic"], "english": item["english"]};
    }).toList();

    setState(() {
      _words = data.reversed.toList();
      // we use "reversed" to sort items in order from the latest to the oldest
    });
  }

  void delete() {
    _mybox.delete(1);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    read();
  }

  List<Map<String, dynamic>> _words = [];

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _mybox.add(newItem);
    read();
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _mybox.put(itemKey, item);
    read();
  }

  Future<void> _deleteItem(int itemKey) async {
    await _mybox.delete(itemKey);
    read();
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existing =
          _words.firstWhere((element) => element['key'] == itemKey);
      _oromic.text = existing['oromic'];
      _english.text = existing['english'];
    }
    showModalBottomSheet(
      context: ctx,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 15,
            left: 15,
            right: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _oromic,
              decoration: InputDecoration(
                label: Text('Oromic'),
              ),
            ),
            TextField(
              controller: _english,
              decoration: InputDecoration(
                label: Text('English'),
              ),
            ),
            MaterialButton(
              onPressed: () async {
                if (itemKey == null) {
                  _createItem(
                      {"oromic": _oromic.text, "english": _english.text});
                }

                if (itemKey != null) {
                  _updateItem(itemKey,
                      {"oromic": _oromic.text, "english": _english.text});
                }
                _english.text = "";
                _oromic.text = '';
                read();
                Navigator.of(context).pop();
              },
              child: Text(itemKey == null ? 'create new' : 'update'),
              color: Colors.blue[200],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ኦሮምኛ በቀላሉ'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 3, 13, 22), Colors.blue])),
        ),
      ),
      body: ListView.builder(
          itemCount: _words.length,
          itemBuilder: (_, index) {
            final currentItem = _words[index];
            return Card(
              margin: EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 9, 47, 129),
                      Color.fromARGB(255, 76, 162, 233)
                    ],
                  ),
                ),
                child: ListTile(
                  title: Text(
                    currentItem["oromic"],
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  subtitle: Text(
                    currentItem["english"].toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          _showForm(context, currentItem['key']);
                        },
                        icon: Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () {
                          _deleteItem(currentItem['key']);
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _showForm(context, null), child: Icon(Icons.add)),
    );
  }
}
