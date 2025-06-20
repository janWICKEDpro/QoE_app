class Statistic {
  final int? id; // Nullable for creation (auto-incremented by Supabase)
  final DateTime? createdAt; // Nullable for creation (set by Supabase)
  final int? deviceId; // Nullable as per Supabase table
  final String? carrierName; // Nullable as per Supabase table
  final double? jitter; // 'real' maps to double
  final double? latency; // 'real' maps to double
  final String? signalStrength; // 'text' maps to String
  final double? packetLoss; // 'real' maps to double
  final double? bandwidth; // 'real' maps to double
  final String? locationName; // Nullable as per Supabase table
  final double? longitude; // Renamed 'long' to 'longitude' for clarity in Dart
  final double? latitude; // Renamed 'lat' to 'latitude' for clarity in Dart
  final String? networkType;
  final String? ip;

  Statistic({
    this.id,
    this.createdAt,
    this.deviceId,
    this.carrierName,
    this.jitter,
    this.latency,
    this.signalStrength,
    this.packetLoss,
    this.bandwidth,
    this.locationName,
    this.longitude,
    this.latitude,
    this.networkType,
    this.ip,
  });

  factory Statistic.fromJson(Map<String, dynamic> json) {
    return Statistic(
      id: json['id'] as int?, // Safely cast to int?, handles null
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null, // Parse DateTime string, handles null
      deviceId: json['device_id'] as int?,
      carrierName: json['carrier_name'] as String?,
      jitter: json['jitter'] as double?,
      latency: json['latency'] as double?,
      signalStrength: json['signal_strength'] as String?,
      packetLoss: json['packet_loss'] as double?,
      bandwidth: json['bandwidth'] as double?,
      locationName: json['location_name'] as String?,
      longitude: json['long'] as double?, // Use 'long' from JSON
      latitude: json['lat'] as double?, // Use 'lat' from JSON
      networkType: json['network_type'] as String?,
      ip: json['ip'] as String?,
    );
  }

  // Method to convert a Statistic object to a JSON map (e.g., for Supabase insertion/update)
  Map<String, dynamic> toJson() {
    return {
      // 'id' is intentionally omitted here for INSERT operations as it's auto-incremented.
      // 'created_at' is usually set by Supabase's `now()` default value.
      // If you are sending an 'id' for an UPDATE operation, you would include it conditionally.
      'device_id': deviceId,
      'carrier_name': carrierName,
      'jitter': jitter,
      'latency': latency,
      'signal_strength': signalStrength,
      'packet_loss': packetLoss,
      'bandwidth': bandwidth,
      'location_name': locationName,
      'long': longitude,
      'lat': latitude,
      'network_type': networkType,
      'ip': ip,
    };
  }

  // Optional: Add a copyWith method for immutability and easy updates
  Statistic copyWith({
    int? id,
    DateTime? createdAt,
    int? deviceId,
    String? carrierName,
    double? jitter,
    double? latency,
    String? signalStrength,
    double? packetLoss,
    double? bandwidth,
    String? locationName,
    double? longitude,
    double? latitude,
    String? networkType,
    String? ip,
  }) {
    return Statistic(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      deviceId: deviceId ?? this.deviceId,
      carrierName: carrierName ?? this.carrierName,
      jitter: jitter ?? this.jitter,
      latency: latency ?? this.latency,
      signalStrength: signalStrength ?? this.signalStrength,
      packetLoss: packetLoss ?? this.packetLoss,
      bandwidth: bandwidth ?? this.bandwidth,
      locationName: locationName ?? this.locationName,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      networkType: networkType ?? this.networkType,
      ip: ip ?? this.ip,
    );
  }

  // Optional: Override toString for better debugging
  @override
  String toString() {
    return 'Statistic(id: $id, createdAt: $createdAt, deviceId: $deviceId, '
        'carrierName: $carrierName, jitter: $jitter, latency: $latency, '
        'signalStrength: $signalStrength, packetLoss: $packetLoss, '
        'bandwidth: $bandwidth, locationName: $locationName, '
        'longitude: $longitude, latitude: $latitude, networkType: $networkType, ip: $ip)';
  }
}
