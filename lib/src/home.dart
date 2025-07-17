import 'package:flutter/material.dart';
import 'package:my_manga/src/list.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MyManga Home')),
      body: SafeArea(
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
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Wifu Kesayangan",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 20.0,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 20.0,
                width: 150.0,
                child: Divider(color: Colors.grey.shade800),
              ),
              Center(         
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ListManga(),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: const Icon(Icons.people, color: Colors.teal),
                    title: Text(
                      "Klik Untuk melihat list manga",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
