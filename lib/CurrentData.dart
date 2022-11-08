import 'dart:io';

import 'package:flutter/material.dart';

class CurrentData {
  Image imageDefault = Image.asset("assets/profile_placeholder.png");
  String? email;
  String? name;
  String? address;
  String? university;
  File currentImage = File("${Directory.systemTemp.path}/tmpImage");
  static CurrentData sharedData = CurrentData();
}
