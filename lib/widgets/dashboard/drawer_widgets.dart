import 'package:flutter/material.dart';

Widget buildDrawerItem(BuildContext context, IconData icon, String title, Widget page) {
  return ListTile(
    leading: Icon(icon, color: Colors.blue),
    title: Text(title),
    onTap: () {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    },
  );
}
