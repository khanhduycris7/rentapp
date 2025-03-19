class ContractModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String carId;
  final String carModel;
  final DateTime rentDate;
  final int rentDurationHours;
  final String pickupLocation;
  final String note;
  final String status;
  final DateTime createdAt;

  ContractModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.carId,
    required this.carModel,
    required this.rentDate,
    required this.rentDurationHours,
    required this.pickupLocation,
    required this.note,
    required this.status,
    required this.createdAt,
  });

  factory ContractModel.fromMap(Map<String, dynamic> map, String docId) {
    return ContractModel(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      carId: map['carId'] ?? '',
      carModel: map['carModel'] ?? '',
      rentDate: DateTime.parse(map['rentDate']),
      rentDurationHours: map['rentDurationHours'] ?? 0,
      pickupLocation: map['pickupLocation'] ?? '',
      note: map['note'] ?? '',
      status: map['status'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
