import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smartfit/features/body_dect/model/body_detect_model.dart';
import 'package:smartfit/features/body_dect/views/body_detect_guided_camera_view.dart';

class BodyDetectView extends StatefulWidget {
  const BodyDetectView({super.key});

  @override
  State<BodyDetectView> createState() => _BodyDetectViewState();
}

class _BodyDetectViewState extends State<BodyDetectView> {
  final vm = BodyDetectModel();
  File? image;

  @override
  void initState() {
    super.initState();
    vm.init();
  }

  Future<void> _openGuidedCamera() async {
    final file = await Navigator.of(context).push<File>(
      MaterialPageRoute(
        builder: (context) => const BodyDetectGuidedCameraView(),
      ),
    );
    if (file == null || !mounted) return;
    setState(() => image = file);
    await vm.analyzeBody(image!);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Body Size Detection')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            image != null
                ? Image.file(image!, height: 250)
                : const Icon(Icons.accessibility, size: 200),

            const SizedBox(height: 20),

            Column(
              children: [
                const Text(
                  'Stand so your full body fits inside the frame for accurate sizing.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _openGuidedCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take photo for body size'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (vm.loading) const CircularProgressIndicator(),

            if (vm.error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  vm.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

            if (vm.topSize != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Size: ${vm.topSize}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bottom Size: ${vm.bottomSize}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      '📊 Debug / Calibration Info:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Ratio percentages — most important for calibration
                    if (vm.upperRatio != null)
                      Text(
                        'Shoulder/Height ratio: '
                        '${(vm.upperRatio! * 100).toStringAsFixed(1)}%'
                        '  (${vm.upperRatio!.toStringAsFixed(4)})',
                        style: TextStyle(
                          fontSize: 13,
                          color: vm.upperRatio! < 0.10 || vm.upperRatio! > 0.50
                              ? Colors.orange
                              : Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (vm.lowerRatio != null)
                      Text(
                        'Hip/Height ratio: '
                        '${(vm.lowerRatio! * 100).toStringAsFixed(1)}%'
                        '  (${vm.lowerRatio!.toStringAsFixed(4)})',
                        style: TextStyle(
                          fontSize: 13,
                          color: vm.lowerRatio! < 0.08 || vm.lowerRatio! > 0.45
                              ? Colors.orange
                              : Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 6),
                    // Raw values
                    if (vm.shoulderWidth != null)
                      Text(
                        'Shoulder span: ${vm.shoulderWidth!.toStringAsFixed(3)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    if (vm.hipWidth != null)
                      Text(
                        'Hip span: ${vm.hipWidth!.toStringAsFixed(3)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    if (vm.torsoHeight != null)
                      Text(
                        'Torso height: ${vm.torsoHeight!.toStringAsFixed(3)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    if (vm.legLength != null)
                      Text(
                        'Leg length: ${vm.legLength!.toStringAsFixed(3)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(height: 6),
                    const Text(
                      '💡 If sizes are wrong, check the ratio% values above\n'
                      'and adjust _mapTopSize/_mapBottomSize thresholds.',
                      style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
