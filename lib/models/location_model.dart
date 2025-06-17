class LocationModel {
  final String? address;
  final String? mainLocation;
  final String? townCountry;
  final double? latitude;
  final double? longitude;

  LocationModel({
    this.address,
    this.mainLocation,
    this.townCountry,
    this.latitude,
    this.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return LocationModel();
    }
    return LocationModel(
      address: json['address'] as String?,
      mainLocation: json['main_location'] as String?,
      townCountry: json['town_country'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] is double
              ? json['latitude'] as double
              : double.tryParse(json['latitude'].toString()))
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] is double
              ? json['longitude'] as double
              : double.tryParse(json['longitude'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'main_location': mainLocation,
      'town_country': townCountry,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}