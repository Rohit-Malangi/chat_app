import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class ImageInput extends StatefulWidget {
  const ImageInput({required this.pickedImage, Key? key}) : super(key: key);

  final void Function(File image) pickedImage;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _stordImage;

  _takeImage(int val) async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: (val == 2) ? ImageSource.gallery : ImageSource.camera,
      imageQuality: 80,
      maxWidth: 150,
    );
    if (imageFile == null) {
      return;
    }
    setState(() {
      _stordImage = File(imageFile.path);
    });
    widget.pickedImage(_stordImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          alignment: Alignment.center,
          child: _stordImage != null
              ? Image.file(
                  _stordImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
              : const Text(
                  'No Image Taken',
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _takeImage(1),
                icon: const Icon(Icons.camera_alt),
              ),
              IconButton(
                onPressed: () => _takeImage(2),
                icon: const Icon(Icons.photo),
              ),
            ],
          ),
        )
      ],
    );
  }
}
