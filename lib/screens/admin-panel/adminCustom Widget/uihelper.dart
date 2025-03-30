import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';

ListTile getListTile(IconData icon, String text, Callback onTap) => ListTile(
  leading: Icon(icon, color: Colors.white),
  title: Text(text, style: TextStyle(color: Colors.white, fontSize: 20)),
  onTap: onTap,
);
