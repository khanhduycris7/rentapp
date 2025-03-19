import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'rental_state.dart';

class RentalCubit extends Cubit<RentalState> {
  RentalCubit() : super(RentalInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> rentCar({
    required String carId,
    required String carModel,
    required DateTime rentDate,
    required int rentDurationHours,
    required String pickupLocation,
    required int price,
    String note = '',
  }) async {
    emit(RentalLoading());

    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(const RentalFailure('Chưa đăng nhập.'));
        return;
      }

      // Lấy thông tin user từ Firestore (nếu cần)
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userInfo = userDoc.data();

      if (userInfo == null) {
        emit(const RentalFailure('Không tìm thấy thông tin người dùng.'));
        return;
      }

      final rentalData = {
        'carId': carId,
        'carModel': carModel,
        'userId': user.uid,
        'userName': userInfo['fullName'] ?? '',
        'userPhone': userInfo['phoneNumber'] ?? '',
        'rentDate': rentDate.toIso8601String(),
        'rentDurationHours': rentDurationHours,
        'pickupLocation': pickupLocation,
        'note': note,
        'status': 'Đang chờ duyệt',
        'createdAt': DateTime.now().toIso8601String(),
        'price': price,
      };

      await _firestore.collection('rentals').doc(carId).set(rentalData);
      print('Car ID cần cập nhật: $carId');
      await _firestore.collection('cars').doc(carId).update({
        'status': 'Đang chờ duyệt'
      });

      emit(RentalSuccess(rentalData: rentalData));
    } catch (e) {
      emit(RentalFailure(e.toString()));
    }
  }
}
