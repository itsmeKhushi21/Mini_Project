import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

part 'models.dart';
part 'core.dart';
part 'admin.dart';
part 'manager.dart';
part 'citizen.dart';
part 'driver.dart';

void main() => runApp(const GarbageApp());
