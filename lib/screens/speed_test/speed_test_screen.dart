import 'package:flutter/material.dart';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';
import 'dart:math';

import 'package:hugeicons/hugeicons.dart';

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen>
    with SingleTickerProviderStateMixin {
  final FlutterInternetSpeedTest _speedTest = FlutterInternetSpeedTest();
  bool _isTesting = false;
  double _downloadSpeed = 0;
  SpeedUnit _downloadUnit = SpeedUnit.mbps;
  SpeedUnit _uploadUnit = SpeedUnit.mbps;
  double _uploadSpeed = 0;
  String _testPhase = 'Ready to test';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addListener(() {
      setState(() {});
    });

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _speedTest.cancelTest();
    _animationController.dispose();
    super.dispose();
  }

  void _startTest() {
    setState(() {
      _isTesting = true;
      _downloadSpeed = 0;
      _uploadSpeed = 0;
      _testPhase = 'Initializing...';
      _animationController.repeat();
    });

    _speedTest.startTesting(
      onStarted: () {
        setState(() {
          _testPhase = 'Testing Internet speed Please stay on this screen...';
        });
      },
      onDownloadComplete: (result) {
        setState(() {
          _downloadSpeed = result.transferRate;
          _downloadUnit = result.unit;
        });
      },
      onUploadComplete: (result) {
        setState(() {
          _uploadSpeed = result.transferRate;
          _uploadUnit = result.unit;
          //  _testPhase = 'Testing upload speed...';
        });
      },
      onError: (err1, err2) {
        setState(() {
          _isTesting = false;
          _testPhase = 'Error: ${err1} $err2';
          _animationController.stop();
        });
      },
      onCancel: () {
        setState(() {
          _isTesting = false;
          _testPhase = 'Test cancelled';
          _animationController.stop();
        });
      },
      fileSizeInBytes: 5000000,
      onProgress: (double percent, TestResult data) {
        setState(() {
          _uploadSpeed = data.transferRate;
          _downloadSpeed = data.transferRate;
          _testPhase = 'Testing upload speed...';
        });
      },
      onCompleted: (TestResult download, TestResult upload) {
        setState(() {
          _downloadSpeed = download.transferRate;
          _uploadSpeed = upload.transferRate;
          _downloadUnit = download.unit;
          _uploadUnit = upload.unit;
          _isTesting = false;
          _testPhase = 'Test completed';
          _animationController.stop();
        });
      },
    );
  }

  Widget _buildSpeedIndicator(double speed, SpeedUnit unit, String label) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Text(
          speed.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(unit.name, style: TextStyle(fontSize: 16, color: Colors.white70)),
      ],
    );
  }

  Widget _buildTestButton() {
    return GestureDetector(
      onTap: _isTesting ? null : _startTest,
      child: Transform.scale(
        scale: _scaleAnimation.value,
        child: Transform.rotate(
          angle: _isTesting ? _rotationAnimation.value : 0,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _isTesting ? Colors.blueAccent : Colors.blue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 3,
                ),
              ],
            ),
            child:
                _isTesting
                    ? Icon(
                      _isTesting ? Icons.speed : Icons.play_arrow,
                      size: 40,
                      color: Colors.white,
                    )
                    : HugeIcon(
                      icon: HugeIcons.strokeRoundedPlayCircle,
                      color: Colors.white,
                    ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Internet Speed Test',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSpeedIndicator(
                          _downloadSpeed,
                          _downloadUnit,
                          'Download',
                        ),
                        Container(
                          width: 1,
                          height: 80,
                          color: Colors.grey[700],
                        ),
                        _buildSpeedIndicator(
                          _uploadSpeed,
                          _uploadUnit,
                          'Upload',
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildTestButton(),
                    const SizedBox(height: 20),
                    Text(
                      _testPhase,
                      style: TextStyle(
                        fontSize: 16,
                        color: _isTesting ? Colors.blueAccent : Colors.white70,
                      ),
                    ),
                    if (!_isTesting && _downloadSpeed > 0) ...[
                      const SizedBox(height: 20),
                      Text(
                        _getResultMessage(_downloadSpeed),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (_isTesting)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(
                  minHeight: 5.0,
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getResultMessage(double speed) {
    if (speed < 1) return 'Very slow connection\nNot suitable for most tasks';
    if (speed < 5) return 'slow connection\nBasic browsing only';
    if (speed < 15) return 'Average speed\nGood for HD video';
    if (speed < 50) return 'Fast connection\nGreat for streaming';
    if (speed < 100) return 'Very fast connection\nExcellent for 4K video';
    return 'Extremely fast connection\nPerfect for all uses';
  }
}
