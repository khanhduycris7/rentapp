import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'contract_state.dart';

class ContractCubit extends Cubit<ContractState> {
  ContractCubit() : super(ContractInitial());

  Future<void> signContract(Map<String, dynamic> rentalData, String method) async {
    emit(ContractLoading());
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(const ContractFailure('User chưa đăng nhập!'));
        return;
      }

      await FirebaseFirestore.instance.collection('contracts').add({
        'userId': user.uid,
        'userName': rentalData['userName'],
        'userPhone': rentalData['userPhone'],
        'carId': rentalData['carId'],
        'carModel': rentalData['carModel'],
        'rentDate': rentalData['rentDate'],
        'rentDurationHours': rentalData['rentDurationHours'],
        'pickupLocation': rentalData['pickupLocation'],
        'note': rentalData['note'],
        'status': 'active',
        'method': method,
        'total_amount': rentalData['price'],
        'createdAt': DateTime.now().toIso8601String(),
      });
      // Sau khi thêm thành công
      emit(ContractSigned());
      print('Thành công');
    } catch (e) {
      emit(ContractFailure(e.toString()));
      print('Lỗi: $e');
    }
  }

}
