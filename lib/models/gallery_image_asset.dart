import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class GalleryImageAsset {
  Uint8List bytes;
  String id;
  DateTime created;
  String location;

  GalleryImageAsset({
    this.bytes,
    this.id,
    this.created,
    this.location,
  });

  Future<File> toFile() async {
    final directory = await getApplicationDocumentsDirectory();

    final String name = Uuid().v1();

    final path = directory.path + "/" + name;

    final buffer = bytes.buffer;
    return File(path).writeAsBytes(buffer.asUint8List(
      bytes.offsetInBytes,
      bytes.lengthInBytes,
    ));
  }
}
