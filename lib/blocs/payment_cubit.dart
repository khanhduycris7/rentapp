import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(PaymentInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> makePayment({
    required String rentalId,
    required int amount,
    required String method,
  }) async {
    emit(PaymentLoading());

    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(const PaymentFailure('Chưa đăng nhập.'));
        return;
      }

      final paymentData = {
        'rentalId': rentalId,
        'userId': user.uid,
        'method': method,
        'amount': amount,
        'status': 'completed', // fake luôn là thanh toán xong
        'paidAt': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('payments').add(paymentData);

      // // Cập nhật rental status (nếu muốn)
      // await _firestore.collection('rentals').doc(rentalId).update({
      //   'status': 'paid',
      // });

      emit(PaymentSuccess());
    } catch (e) {
      emit(PaymentFailure(e.toString()));
    }
  }
}
