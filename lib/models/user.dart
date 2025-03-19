class UserModel {
  String uid;
  String email;
  String fullName;
  String phoneNumber;
  String address;
  String dateOfBirth;
  String idCardNumber;
  String driverLicense;
  String profileImage;
  String idCardImagePath;
  String driverLicenseImagePath;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.dateOfBirth,
    required this.idCardNumber,
    required this.driverLicense,
    required this.profileImage,
    required this.idCardImagePath,
    required this.driverLicenseImagePath,
  });

  // Tạo model từ Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      idCardNumber: map['idCardNumber'] ?? '',
      driverLicense: map['driverLicense'] ?? '',
      profileImage: map['profileImage'] ?? '',
      idCardImagePath: map['idCardImagePath'] ?? '',
      driverLicenseImagePath: map['driverLicenseImagePath'] ?? '',
    );
  }

  // Convert model thành Map để lưu Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'dateOfBirth': dateOfBirth,
      'idCardNumber': idCardNumber,
      'driverLicense': driverLicense,
      'profileImage': profileImage,
      'idCardImagePath': idCardImagePath,
      'driverLicenseImagePath': driverLicenseImagePath,
    };
  }

  // Đây là copyWith
  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? dateOfBirth,
    String? idCardNumber,
    String? driverLicense,
    String? profileImage,
    String? idCardImagePath,
    String? driverLicenseImagePath,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      idCardNumber: idCardNumber ?? this.idCardNumber,
      driverLicense: driverLicense ?? this.driverLicense,
      profileImage: profileImage ?? this.profileImage,
      idCardImagePath: idCardImagePath ?? this.idCardImagePath,
      driverLicenseImagePath: driverLicenseImagePath ?? this.driverLicenseImagePath,
    );
  }
}
