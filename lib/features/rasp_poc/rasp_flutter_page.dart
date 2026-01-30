import 'package:flutter/material.dart';
import 'package:freerasp/freerasp.dart';
import '../../core/security/dialogs/security_dialog.dart';

class RASPFlutterPage extends StatefulWidget {
  const RASPFlutterPage({super.key});

  @override
  State<RASPFlutterPage> createState() => _RASPFlutterPageState();
}

class _RASPFlutterPageState extends State<RASPFlutterPage> {
  // Detection status
  bool? _isRootDetected;
  bool? _isDebugModeDetected;
  bool? _isDeveloperModeDetected;
  bool? _isEmulatorDetected;
  bool? _isHookDetected;
  bool? _isAppIntegrityFailed;

  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _attachRaspListener();
  }

  void _attachRaspListener() {
    // Listen to real-time RASP events
    Talsec.instance.attachListener(
      ThreatCallback(
        onDebug: () {
          if (mounted) {
            setState(() {
              _isDebugModeDetected = true;
              _isDeveloperModeDetected = true;
            });
            _showThreatModal(
              'USB Debugging Detected',
              'ตรวจพบการเปิด USB Debugging บนอุปกรณ์',
            );
          }
        },
        onHooks: () {
          if (mounted) {
            setState(() {
              _isRootDetected = true;
              _isHookDetected = true;
            });
            _showThreatModal(
              'Root/Hook Detected',
              'ตรวจพบการ Root เครื่องหรือมี Hook Framework',
            );
          }
        },
        onSimulator: () {
          if (mounted) {
            setState(() {
              _isEmulatorDetected = true;
            });
            _showThreatModal(
              'Emulator Detected',
              'ตรวจพบการใช้งานบน Emulator/Simulator',
            );
          }
        },
        onAppIntegrity: () {
          if (mounted) {
            setState(() {
              _isAppIntegrityFailed = true;
            });
            _showThreatModal(
              'App Integrity Failed',
              'ตรวจพบการแก้ไขหรือ Tampering แอปพลิเคชัน',
            );
          }
        },
        onUnofficialStore: () {},
        onDeviceBinding: () {},
        onPasscode: () {},
        onSecureHardwareNotAvailable: () {},
      ),
    );
  }

  void _showThreatModal(String title, String message) {
    SecurityDialog.show(title: title, message: message);
  }

  Future<void> _runManualChecks() async {
    setState(() {
      _isChecking = true;
    });

    // Simulate checking delay for UI feedback
    await Future.delayed(const Duration(milliseconds: 500));

    // Note: freerasp works in background and triggers callbacks
    // We'll mark as "checked" and wait for callbacks
    setState(() {
      // If no detection yet, mark as safe
      _isRootDetected ??= false;
      _isDebugModeDetected ??= false;
      _isDeveloperModeDetected ??= false;
      _isEmulatorDetected ??= false;
      _isHookDetected ??= false;
      _isAppIntegrityFailed ??= false;
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RASP Security Checklist'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RASP Security Detection',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Runtime Application Self-Protection',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Description Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'เกี่ยวกับการทดสอบ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ระบบจะตรวจสอบความเสี่ยงด้านความปลอดภัย '
                      'เมื่อตรวจพบความเสี่ยง จะแสดง Modal แจ้งเตือน',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Legend
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(
                      icon: Icons.check_circle,
                      color: Colors.green,
                      text: 'ปลอดภัย - ไม่พบความเสี่ยง',
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                      icon: Icons.cancel,
                      color: Colors.red,
                      text: 'ตรวจพบความเสี่ยง - จะแสดง Modal',
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                      icon: Icons.help_outline,
                      color: Colors.grey,
                      text: 'ยังไม่ได้ตรวจสอบ',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Security Checklist

            _buildChecklistItem(
              number: '1',
              title: 'Root Detection',
              subtitle: 'ตรวจจับ Root ของเครื่องที่ใช้งาน',
              status: _isRootDetected,
            ),
            const Divider(height: 32),

            _buildChecklistItem(
              number: '2',
              title: 'USB Debugging Detection',
              subtitle: 'ตรวจจับโหมด USB Debugging',
              status: _isDebugModeDetected,
            ),
            const Divider(height: 32),

            _buildChecklistItem(
              number: '3',
              title: 'Developer Mode Detection',
              subtitle: 'ตรวจจับการเปิด Developer Mode',
              status: _isDeveloperModeDetected,
            ),
            const Divider(height: 32),

            _buildChecklistItem(
              number: '4',
              title: 'Emulator Detection',
              subtitle: 'ตรวจจับการใช้งานบน Emulator/Simulator',
              status: _isEmulatorDetected,
            ),
            const Divider(height: 32),

            _buildChecklistItem(
              number: '5',
              title: 'Hook Framework Detection',
              subtitle: 'ตรวจจับ Frida, Magisk, Xposed',
              status: _isHookDetected,
            ),
            const Divider(height: 32),

            _buildChecklistItem(
              number: '6',
              title: 'App Integrity Check',
              subtitle: 'ตรวจสอบการแก้ไขหรือ Re-sign แอป',
              status: _isAppIntegrityFailed != null
                  ? !_isAppIntegrityFailed!
                  : null,
            ),
            const SizedBox(height: 32),

            // Run Check Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isChecking ? null : _runManualChecks,
                icon: _isChecking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(
                  _isChecking ? 'กำลังตรวจสอบ...' : 'เริ่มการตรวจสอบ',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem({
    required String number,
    required String title,
    required String subtitle,
    required bool? status,
  }) {
    IconData iconData;
    Color iconColor;
    String statusText;

    if (status == null) {
      iconData = Icons.help_outline;
      iconColor = Colors.grey;
      statusText = 'รอตรวจสอบ';
    } else if (status) {
      iconData = Icons.cancel;
      iconColor = Colors.red;
      statusText = 'ตรวจพบความเสี่ยง';
    } else {
      iconData = Icons.check_circle;
      iconColor = Colors.green;
      statusText = 'ปลอดภัย';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number badge
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue[700],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Status icon and text
        Column(
          children: [
            Icon(
              iconData,
              color: iconColor,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                color: iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
