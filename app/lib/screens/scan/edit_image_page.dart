import 'package:flutter/material.dart';

class EditImagePage extends StatefulWidget {
  final ImageProvider? image;
  const EditImagePage({super.key, this.image});

  @override
  State<EditImagePage> createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {
  double _brightness = 0.0; // 0 = normal, -1 = dark, 1 = bright

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Image'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Image Preview',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 220,
                  child: widget.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.matrix(
                              _brightnessMatrix(_brightness),
                            ),
                            child: Image(
                              image: widget.image!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.image,
                            size: 90,
                            color: Colors.grey[400],
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Adjustments',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.brightness_6,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Expanded(
                  child: Slider(
                    value: _brightness,
                    min: -1.0,
                    max: 1.0,
                    divisions: 20,
                    label: _brightness == 0
                        ? 'Normal'
                        : _brightness > 0
                        ? 'Bright'
                        : 'Dark',
                    onChanged: (value) {
                      setState(() {
                        _brightness = value;
                      });
                    },
                  ),
                ),
                Text(
                  'Brightness',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Image Actions',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Add pick image logic
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Add take photo logic
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Add crop/rotate logic
                  },
                  icon: const Icon(Icons.crop),
                  label: const Text('Crop'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Add rotate logic
                  },
                  icon: const Icon(Icons.rotate_right),
                  label: const Text('Rotate'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Save/confirm changes
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.save,
                      color: Theme.of(context).colorScheme.primary,
                      size: 26,
                    ),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'Save Changes',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                              letterSpacing: 0.2,
                            ),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shadowColor: Colors.black.withOpacity(0.08),
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.primary,
                      size: 26,
                    ),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'Cancel',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                              letterSpacing: 0.2,
                            ),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shadowColor: Colors.black.withOpacity(0.08),
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper to create a color matrix for brightness
  List<double> _brightnessMatrix(double brightness) {
    return [
      1,
      0,
      0,
      0,
      255 * brightness,
      0,
      1,
      0,
      0,
      255 * brightness,
      0,
      0,
      1,
      0,
      255 * brightness,
      0,
      0,
      0,
      1,
      0,
    ];
  }
}
