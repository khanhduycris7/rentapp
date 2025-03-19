class VoucherModel {
  final String id;
  final double value; // Giảm bao nhiêu %
  final String code;

  VoucherModel({
    required this.id,
    required this.value,
    required this.code,
  });

  factory VoucherModel.fromMap(Map<String, dynamic> data, String documentId) {
    return VoucherModel(
      id: documentId,
      value: (data['value'] ?? 0.0).toDouble(), // ví dụ: 0.1 = 10%
      code: documentId, // Dùng documentId làm mã code (phatgiam10)
    );
  }
}