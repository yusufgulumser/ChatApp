import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class InputImage extends StatefulWidget {
  const InputImage({super.key, required this.onPickImage});
  final void Function(File theImage) onPickImage;
  @override
  State<StatefulWidget> createState() {
    return _InputImageState();
  }
}

class _InputImageState extends State<InputImage> {
  File? _selectedImage;

  void _inputImage() async {
    final pickedImage = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 160);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      _selectedImage = File(pickedImage.path);
    });
    widget.onPickImage(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color.fromARGB(255, 155, 151, 151),
          foregroundImage:
              _selectedImage != null ? FileImage(_selectedImage!) : null,
        ),
        TextButton.icon(
            onPressed: _inputImage,
            icon: const Icon(Icons.image_outlined),
            label: Text('Add an image',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                )))
      ],
    );
  }
}
