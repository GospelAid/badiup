import 'package:badiup/models/gallery_image_asset.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MultiSelectGallery extends StatefulWidget {
  @override
  _MultiSelectGalleryState createState() => _MultiSelectGalleryState();
}

class _MultiSelectGalleryState extends State<MultiSelectGallery> {
  final _channel = MethodChannel("/gallery");

  var _numberOfItems = 0;
  var _selectedImages = List<GalleryImageAsset>();
  var _imageAssetCache = Map<int, GalleryImageAsset>();

  @override
  void initState() {
    super.initState();

    _channel.invokeMethod<int>("getItemCount").then((count) {
      setState(() {
        _numberOfItems = count;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gallery"),
        actions: <Widget>[
          FlatButton(
            child: Text("Done"),
            onPressed: () {
              Navigator.pop(context, _selectedImages.map((img) async {
                return await img.toFile();
              }).toList());
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: _numberOfItems,
        itemBuilder: (context, index) {
          return _buildGalleryTile(index);
        },
      ),
    );
  }

  _buildGalleryTile(int index) {
    return GestureDetector(
      child: Card(
        elevation: 0.0,
        child: FutureBuilder(
          future: _getImageAssetFromDeviceGallery(index),
          builder: (context, snapshot) {
            var item = snapshot?.data;
            if (item != null) {
              return _buildGalleryTileImage(item);
            } else {
              return Container();
            }
          },
        ),
      ),
      onTap: () {
        _selectImage(index);
      },
    );
  }

  Widget _buildGalleryTileImage(item) {
    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Image.memory(item.bytes, fit: BoxFit.cover),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(4),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isSelected(item.id) ? Colors.blue : Colors.transparent,
              border: Border.all(color: Colors.white, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  _selectImage(int index) async {
    var galleryImage = await _getImageAssetFromDeviceGallery(index);

    setState(() {
      if (_isSelected(galleryImage.id)) {
        _selectedImages.removeWhere((anItem) {
          return anItem.id == galleryImage.id;
        });
      } else {
        _selectedImages.add(galleryImage);
      }
    });
  }

  _isSelected(String id) {
    return _selectedImages.where((item) => item.id == id).length > 0;
  }

  Future<GalleryImageAsset> _getImageAssetFromDeviceGallery(
    int index,
  ) async {
    if (_imageAssetCache[index] != null) {
      return _imageAssetCache[index];
    } else {
      var channelResponse = await _channel.invokeMethod(
        "getItem",
        index,
      );
      var imageAsset = Map<String, dynamic>.from(channelResponse);

      var galleryImageAsset = GalleryImageAsset(
        bytes: imageAsset['data'],
        id: imageAsset['id'],
        created: DateTime.fromMillisecondsSinceEpoch(
          imageAsset['created'] * 1000,
        ),
        location: imageAsset['location'],
      );

      _imageAssetCache[index] = galleryImageAsset;

      return galleryImageAsset;
    }
  }
}
