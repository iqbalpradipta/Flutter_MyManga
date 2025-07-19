import 'package:flutter/material.dart';
import 'package:my_manga/src/list.dart';
import 'package:my_manga/src/widget/bottom_nav.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    MyHome(),
    Center(child: Text('Halaman Search')),
    ListManga(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MyManga Home')),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class MyHome extends StatelessWidget {
  const MyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircleAvatar(
              radius: 50.0,
              backgroundImage: NetworkImage(
                'https://i.scdn.co/image/ab67616d0000b2736f157409ae8578b9695be2b3',
              ),
            ),
            const Text(
              "Furina",
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Wifu Kesayangan",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20.0,
                letterSpacing: 2.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20.0,
              width: 150.0,
              child: Divider(color: Colors.grey),
            ),
            Center(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ListManga()),
                  );
                },
                child: const ListTile(
                  leading: Icon(Icons.people, color: Colors.teal),
                  title: Text(
                    "Klik Untuk melihat list manga",
                    style: TextStyle(color: Colors.grey, fontSize: 20.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
