import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Widget para seleccionar y previsualizar una imagen (cámara o galería)
class ImagePickerSection extends StatefulWidget {
  final Function(File?) onImageSelected;
  final File? initialImage;

  const ImagePickerSection({
    super.key,
    required this.onImageSelected,
    this.initialImage,
  });

  @override
  State<ImagePickerSection> createState() => _ImagePickerSectionState();
}

class _ImagePickerSectionState extends State<ImagePickerSection> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        setState(() {
          _selectedImage = file;
        });
        widget.onImageSelected(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al tomar foto: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        setState(() {
          _selectedImage = file;
        });
        widget.onImageSelected(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Previsualización de imagen
        if (_selectedImage != null) ...[
          Stack(
            children: [
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  onPressed: _removeImage,
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImageFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cambiar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                ),
              ),
            ],
          ),
        ] else ...[
          // Botones de selección cuando no hay imagen
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline,
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  size: 64,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Agregar foto del alimento',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _pickImageFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cámara'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _pickImageFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
