import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:qoe_app/routes/route_names.dart';
import 'package:qoe_app/providers/network_info_provider.dart';
import 'dart:io' show Platform;

class NetworkDashboardScreen extends StatefulWidget {
  const NetworkDashboardScreen({super.key});

  @override
  _NetworkDashboardScreenState createState() => _NetworkDashboardScreenState();
}

class _NetworkDashboardScreenState extends State<NetworkDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NetworkInfoProvider>(
        context,
        listen: false,
      ).fetchNetworkInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset("assets/images/feedback1.png", height: 32),
            ),
            const SizedBox(width: 10),
            const Text('Feedback'),
          ],
        ),
        actions: [
          IconButton(
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedSettings01,
              color: Colors.black,
              size: 30.0,
            ),
            onPressed: () {
              context.goNamed(RoutePath.settings);
            },
          ),
        ],
      ),
      body: Consumer<NetworkInfoProvider>(
        builder: (context, networkInfo, child) {
          if (networkInfo.isLoading &&
              networkInfo.signalStrength == 0 &&
              networkInfo.numberOfSimCards == 0 &&
              networkInfo.phoneModel == "Unknown Device") {
            return const Center(child: CircularProgressIndicator());
          }
          if (networkInfo.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  networkInfo.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await Provider.of<NetworkInfoProvider>(
                context,
                listen: false,
              ).fetchNetworkInfo();
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSignalStrengthCard(networkInfo),
                  const SizedBox(height: 16),
                  _buildSimInfoCard(networkInfo),
                  const SizedBox(height: 16),
                  _buildDeviceInfoCard(networkInfo),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignalStrengthCard(NetworkInfoProvider networkInfo) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Network Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedCellularNetwork,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Signal Strength',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      // Only show signal strength on Android
                      if (Platform.isAndroid)
                        Row(
                          children: List.generate(5, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.network_wifi,
                                size: 20,
                                color:
                                    index < networkInfo.signalStrength
                                        ? _getSignalColor(
                                          networkInfo.signalStrength,
                                        )
                                        : Colors.grey[300],
                              ),
                            );
                          }),
                        )
                      else
                        const Text(
                          'Not available on iOS',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Carrier',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        networkInfo.currentCarrier,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimInfoCard(NetworkInfoProvider networkInfo) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SIM Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedSimcard02,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Number of SIMs',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${networkInfo.numberOfSimCards}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Internet SIM',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        networkInfo.currentSimForInternet,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (networkInfo.simCardDetails.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'SIM Card Details:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 8),
              ...networkInfo.simCardDetails.map(
                (sim) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    'SIM ${sim.slotIndex}: ${sim.carrierName} (MCC: ${sim.displayName}, MNC: ${sim.countryPhonePrefix})',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard(NetworkInfoProvider networkInfo) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Device Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedSmartPhone01,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Location',
              networkInfo.currentLocation,
              HugeIcons.strokeRoundedLocation05,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'OS Version',
              networkInfo.osVersion,
              HugeIcons.strokeRoundedAndroid,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Phone Model',
              networkInfo.phoneModel,
              HugeIcons.strokeRoundedSmartPhone03,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        HugeIcon(icon: icon, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getSignalColor(int strength) {
    if (strength >= 4) return Colors.green;
    if (strength >= 2) return Colors.orange;
    return Colors.red;
  }
}
