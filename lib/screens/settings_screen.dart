import 'package:flutter/material.dart';
import '../services/battery_optimization_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isBatteryOptimizationEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkBatteryOptimization();
  }

  Future<void> _checkBatteryOptimization() async {
    setState(() => _isLoading = true);
    final isEnabled = await BatteryOptimizationService.isBatteryOptimizationEnabled();
    setState(() {
      _isBatteryOptimizationEnabled = isEnabled;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_isBatteryOptimizationEnabled)
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 32),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Battery Optimization Detected',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your device may kill the step counter in the background. '
                            'This is the most common reason for missing steps.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange.shade900,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await BatteryOptimizationService.openBatteryOptimizationSettings();
                              // Recheck after user returns
                              Future.delayed(const Duration(seconds: 1), _checkBatteryOptimization);
                            },
                            icon: const Icon(Icons.settings),
                            label: const Text('Open Settings'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade700,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Battery optimization is disabled\nStep counting should work reliably',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                const Text(
                  'How to Disable Battery Optimization',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      BatteryOptimizationService.getDeviceSpecificInstructions(),
                      style: const TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Why This Matters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '• Phone manufacturers add aggressive battery optimization',
                          style: TextStyle(fontSize: 14, height: 1.6),
                        ),
                        Text(
                          '• These optimizations kill background apps to save battery',
                          style: TextStyle(fontSize: 14, height: 1.6),
                        ),
                        Text(
                          '• Even foreground services with notifications can be killed',
                          style: TextStyle(fontSize: 14, height: 1.6),
                        ),
                        Text(
                          '• Disabling optimization ensures the step counter runs 24/7',
                          style: TextStyle(fontSize: 14, height: 1.6),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Without this setting, you may see days with zero steps or only partial counts.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
