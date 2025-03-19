class RentalModel {
  final String id;
  final String carId;
  final String carModel;
  final String userId;
  final String userName;
  final String userPhone;
  final DateTime rentDate;
  final int rentDurationHours;
  final String pickupLocation;
  final String note;
  final String status;
  final DateTime createdAt;
  final int price;

  RentalModel({
    required this.id,
    required this.carId,
    required this.carModel,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.rentDate,
    required this.rentDurationHours,
    required this.pickupLocation,
    required this.note,
    required this.status,
    required this.createdAt,
    required this.price,t
  });

  factory RentalModel.fromMap(Map<String, dynamic> data, String docId) {
    return RentalModel(
      id: docId,
      carId: data['carId'] ?? '',
      carModel: data['carModel'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      rentDate: DateTime.parse(data['rentDate'] ?? DateTime.now().toIso8601String()),
      rentDurationHours: data['rentDurationHours'] ?? 0,
      pickupLocation: data['pickupLocation'] ?? '',
      note: data['note'] ?? '',
      status: data['status'] ?? '',
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      price: data['price'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'carModel': carModel,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'rentDate': rentDate.toIso8601String(),
      'rentDurationHours': rentDurationHours,
      'pickupLocation': pickupLocation,
      'note': note,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'price': price,
    };
  }
}
