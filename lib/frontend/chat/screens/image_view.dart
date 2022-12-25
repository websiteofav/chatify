import 'dart:io';

import 'package:chat_app/frontend/utils/colors.dart';
import 'package:chat_app/frontend/utils/device_dimensions.dart';
import 'package:chat_app/frontend/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatefulWidget {
  final String imagePath;
  final ImageProviderCategory imageCategory;
  const ImageView(
      {Key? key,
      required this.imagePath,
      this.imageCategory = ImageProviderCategory.fileImage})
      : super(key: key);

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    final dimensions = deviceDimensions(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.textFieldBackgroundColor,
        title: const Text(
          'Image',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 1,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SizedBox(
        height: dimensions[0],
        width: dimensions[1],
        child: PhotoView(
          enableRotation: true,
          initialScale: null,
          loadingBuilder: (ctx, event) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorBuilder: (ctx, obj, stackTrace) => Container(
            alignment: Alignment.center,
            child: const Text('Could not load image',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                )),
          ),
          imageProvider: _getImage(),
        ),
      ),
    );
  }

  _getImage() {
    if (widget.imageCategory == ImageProviderCategory.fileImage) {
      return FileImage(File(widget.imagePath));
    } else if (widget.imageCategory == ImageProviderCategory.assetImage) {
      return ExactAssetImage(widget.imagePath);
    } else {
      return NetworkImage(widget.imagePath);
    }
  }
}
