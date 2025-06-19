class Device {
  final int? id;
  final DateTime? createdAt;
  final String? ipAddress;
  final String? locationName;
  final double? longitude;
  final double? latitude;
  final String? deviceName;
  final int? numberOfSims;
  final String? token;
  final DateTime? updatedAt;

  Device({
    this.id,
    this.createdAt,
    this.ipAddress,
    this.locationName,
    this.longitude,
    this.latitude,
    this.deviceName,
    this.numberOfSims,
    this.token,
    this.updatedAt,
  });

  // Factory constructor to create a Device object from a JSON map (e.g., from Supabase)
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as int?, // Safely cast to int?, handles null
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null, // Parse DateTime string, handles null
      ipAddress: json['ipaddress'] as String?,
      locationName: json['location_name'] as String?,
      longitude: json['long'] as double?, // Use 'long' from JSON
      latitude: json['lat'] as double?, // Use 'lat' from JSON
      deviceName: json['device_name'] as String?,
      numberOfSims: json['number_of_sims'] as int?,
      token: json['token'] as String?,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  // Method to convert a Device object to a JSON map (e.g., for Supabase insertion/update)
  Map<String, dynamic> toJson() {
    return {
      // 'id' is intentionally omitted here for INSERT operations as it's auto-incremented.
      // If you are sending an 'id' for an UPDATE operation, you would include it conditionally.
      // For general purpose, it's often omitted in toJson for objects created client-side.
      'ipaddress': ipAddress,
      'location_name': locationName,
      'long': longitude,
      'lat': latitude,
      'device_name': deviceName,
      'number_of_sims': numberOfSims,
      'token': token,
      // 'created_at' is usually set by Supabase's `now()` default value.
      // 'updated_at' might be handled by a trigger or `now()` default value.
      // If you need to manually set them, uncomment and handle DateTime to ISO 8601 string:
      // 'created_at': createdAt?.toIso8601String(),
      // 'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Optional: Add a copyWith method for immutability and easy updates
  Device copyWith({
    int? id,
    DateTime? createdAt,
    String? ipAddress,
    String? locationName,
    double? longitude,
    double? latitude,
    String? deviceName,
    int? numberOfSims,
    String? token,
    DateTime? updatedAt,
  }) {
    return Device(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      ipAddress: ipAddress ?? this.ipAddress,
      locationName: locationName ?? this.locationName,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      deviceName: deviceName ?? this.deviceName,
      numberOfSims: numberOfSims ?? this.numberOfSims,
      token: token ?? this.token,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Optional: Override toString for better debugging
  @override
  String toString() {
    return 'Device(id: $id, createdAt: $createdAt, ipAddress: $ipAddress, '
        'locationName: $locationName, longitude: $longitude, latitude: $latitude, '
        'deviceName: $deviceName, numberOfSims: $numberOfSims, token: $token, '
        'updatedAt: $updatedAt)';
  }
}
