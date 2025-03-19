class Car {
  final int id;
  final String model;
  final int distance;
  final String fuelCapacity;
  final int pricePerHour;
  final String codition;
  final String status;
  final String image;            // Ảnh đại diện
  final List<String> images;     // Danh sách nhiều ảnh

  Car({
    required this.id,
    required this.model,
    required this.distance,
    required this.fuelCapacity,
    required this.pricePerHour,
    required this.codition,
    required this.status,
    required this.image,
    required this.images,
  });

  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: (map['id'] ?? 0) as int,
      model: map['model'] ?? '',
      distance: (map['distance'] ?? 0) as int,
      fuelCapacity: map['fuelCapacity'] ?? '',
      pricePerHour: (map['pricePerHour'] ?? 0) as int,
      codition: map['codition'] ?? 'New',
      status: map['status'] ?? 'Available',
      image: map['image'] ?? '',
      images: map['images'] != null
          ? List<String>.from(map['images'])
          : [], // Nếu null thì trả về list rỗng
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'model': model,
      'distance': distance,
      'fuelCapacity': fuelCapacity,
      'pricePerHour': pricePerHour,
      'codition': codition,
      'status': status,
      'image': image,
      'images': images,
    };
  }
}
