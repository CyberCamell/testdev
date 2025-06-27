import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
    child: AppBar(
    backgroundColor: const Color(0xFF4DA6FF),
    centerTitle: true,
    leading: Padding(
    padding: const EdgeInsets.only(top: 20),
    child: IconButton(
    icon: const Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
    onPressed: () {
    Navigator.pop(context);
    },
    ),
    ),
          title: const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'About Us',
              style: TextStyle(color: Colors.white, fontSize: 32),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4DA6FF), Colors.white],
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  FontAwesomeIcons.code,
                  size: 25,
                  color: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 5),
            Text(
              'It is a quick reference for developers\n'
              ' that contains important commands\n '
              'and functions for the most popular\n '
              'programming languages and\n'
              ' frameworks.',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 20),
            Divider(
              color: Colors.white,
              thickness: 0.2,
              endIndent: 30,
              indent: 30,
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Row(
                children: [
                  Text(
                    'Version',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  SizedBox(width: 200),
                  Text(
                    '3.2.1',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(
              color: Colors.white,
              thickness: 0.2,
              endIndent: 30,
              indent: 30,
            ),
            SizedBox(height: 20),
            Text(
              'Dev Guide! Dev Guide Thank you for using\n our goal to make your programming journey\n easier.',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
