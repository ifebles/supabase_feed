import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSelector extends StatefulWidget {
  final void Function(String? name, Uint8List? imageBytes) onImageChanged;
  final String? selectLabel;
  final String? imageUrl;
  final bool canEdit;

  const ImageSelector({
    super.key,
    required this.onImageChanged,
    this.selectLabel,
    this.imageUrl,
    this.canEdit = true,
  });

  @override
  State<ImageSelector> createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {
  Uint8List? imageBytes;
  String? imageUrl;
  String? imageName;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((value) {
      imageUrl = widget.imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    final onImageChanged = widget.onImageChanged;
    final canEdit = widget.canEdit;
    final selectLabel = widget.selectLabel;

    Image? image;

    if (imageUrl != null) {
      image = Image.network(imageUrl!, fit: BoxFit.cover);
    } else if (imageBytes != null) {
      image = Image.memory(imageBytes!, fit: BoxFit.cover);
    }

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: !canEdit
            ? null
            : () async {
                final picker = ImagePicker();
                final image =
                    await picker.pickImage(source: ImageSource.gallery);

                if (image == null) return;

                image.readAsBytes().then((value) {
                  setState(() {
                    imageUrl = null;
                    imageBytes = value;
                    imageName = image.name;
                  });

                  onImageChanged(image.name, value);
                });
              },
        child: Row(
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: Container(
                color: Colors.grey[300],
                child: image ??
                    const Center(
                      child: Text(
                        'No Image',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 20),
            image == null
                ? Text(
                    selectLabel ?? 'Select an image',
                    style: TextStyle(
                      letterSpacing: 1,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        imageName ?? 'Selected element',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ]
                        .followedBy(!canEdit
                            ? []
                            : [
                                const SizedBox(height: 10),
                                const Text(
                                  'Edit image',
                                  style: TextStyle(
                                    letterSpacing: 1,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              ])
                        .toList(),
                  ),
          ]
              .followedBy(!canEdit || imageBytes == null
                  ? []
                  : [
                      const Expanded(child: SizedBox()),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            imageUrl = null;
                            imageBytes = null;
                            imageName = null;
                          });

                          onImageChanged(null, null);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ])
              .toList(),
        ),
      ),
    );
  }
}
