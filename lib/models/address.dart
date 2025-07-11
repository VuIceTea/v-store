class Address {
  String street;
  String village;
  String district;
  String city;
  String country;

  Address({
    required this.street,
    required this.village,
    required this.district,
    required this.city,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] as String,
      village: json['village'] as String,
      district: json['district'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'village': village,
      'district': district,
      'city': city,
      'country': country,
    };
  }
}
