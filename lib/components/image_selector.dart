import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_feed/components/sized_progress_indicator.dart';
import 'package:supabase_feed/enums/loading_status.dart';

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
  LoadingStatus? loadingStatus;
  var _imageKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    imageUrl = widget.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final onImageChanged = widget.onImageChanged;
    final canEdit = widget.canEdit;
    final selectLabel = widget.selectLabel;

    ///

    Widget? image;

    if (imageUrl != null) {
      image = Image.network(
        imageUrl!,
        key: _imageKey,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (frame == null) {
            return const SizedProgressIndicator(
              padding: 20,
              color: Colors.grey,
            );
          }

          if (loadingStatus != LoadingStatus.success) {
            // Setting it before the state update for loadingBuilder
            loadingStatus = LoadingStatus.success;
            Future.delayed(Duration.zero).then((value) =>
                setState(() => loadingStatus = LoadingStatus.success));
          }
          return child;
        },
        errorBuilder: (context, error, stackTrace) {
          const child = Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          );

          if (loadingStatus == LoadingStatus.fail) return child;

          if (kDebugMode) {
            print("$error.\n$stackTrace");
          }

          Future.delayed(Duration.zero).then(
              (value) => setState(() => loadingStatus = LoadingStatus.fail));

          return child;
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingStatus == LoadingStatus.success) return child;

          double? value;

          if (loadingStatus != null && loadingProgress == null) {
            return child;
          } else if (loadingStatus == null) {
            Future.delayed(Duration.zero).then((value) =>
                setState(() => loadingStatus = LoadingStatus.loading));
          }

          if (loadingProgress?.expectedTotalBytes != null) {
            value = loadingProgress!.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!;
          }

          return SizedProgressIndicator(
            value: value,
            padding: 20,
            color: Colors.grey,
          );
        },
      );
    } else if (imageBytes != null) {
      image = Image.memory(imageBytes!, fit: BoxFit.cover);
    }

    ///

    List<Widget>? sideInfo;

    if (loadingStatus == LoadingStatus.loading) {
      sideInfo = [
        const Text('Loading...'),
      ];
    } else if (loadingStatus == LoadingStatus.fail) {
      sideInfo = [
        const Text('Failed to download image'),
        const Text(
          'Tap to retry',
          style: TextStyle(
            letterSpacing: 1,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ];
    } else {
      sideInfo = [
        Container(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Text(
            imageName ?? 'Current element',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ];

      if (canEdit) {
        sideInfo.addAll([
          const SizedBox(height: 10),
          const Text(
            'Edit image',
            style: TextStyle(
              letterSpacing: 1,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ]);
      }
    }

    ///

    void Function()? tapAction;

    if (loadingStatus == LoadingStatus.fail) {
      tapAction = () {
        setState(() {
          _imageKey = UniqueKey();
          loadingStatus = null;
        });
      };
    } else if (canEdit && loadingStatus != LoadingStatus.loading) {
      tapAction = () async {
        final picker = ImagePicker();
        final image = await picker.pickImage(source: ImageSource.gallery);

        if (image == null) return;

        image.readAsBytes().then((value) {
          setState(() {
            imageUrl = null;
            imageBytes = value;
            imageName = image.name;
          });

          onImageChanged(image.name, value);
        });
      };
    }

    ///

    List<Widget> clearBtn = [];

    if (canEdit &&
        (imageBytes != null || loadingStatus == LoadingStatus.success)) {
      clearBtn = [
        const Expanded(child: SizedBox()),
        IconButton(
          onPressed: () {
            setState(() {
              imageUrl = null;
              imageBytes = null;
              imageName = null;
              loadingStatus = null;
            });

            onImageChanged(null, null);
          },
          icon: const Icon(Icons.close),
        ),
      ];
    }

    ///

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: tapAction,
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
                    children: sideInfo,
                  ),
          ].followedBy(clearBtn).toList(),
        ),
      ),
    );
  }
}
