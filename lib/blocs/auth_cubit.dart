import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/user_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthCubit(this._auth) : super(AuthInitial());

  final userService = UserService();


  // Đăng ký
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String driverLicense,
    required String idCardNumber,
    required String address,
    required String dateOfBirth,
  }) async {
    emit(AuthLoading());
    try {
      // Đăng ký với Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Lưu thông tin người dùng vào Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'driverLicense': driverLicense,
          'idCardNumber': idCardNumber,
          'address': address,
          'dateOfBirth': dateOfBirth,
          'profileImage': '', // Nếu có ảnh profile thì upload lên Firebase Storage và lưu link ở đây
        });

        emit(AuthSuccess("Đăng ký thành công!", user.uid));
      } else {
        emit(AuthFailure("Đăng ký thất bại!"));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? "Lỗi không xác định"));
    } catch (e) {
      emit(AuthFailure("Lỗi hệ thống: $e"));
    }
  }



  // Đăng nhập
  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;

      if (uid == null) {
        emit(AuthFailure("Đăng nhập thất bại"));
        return;
      }



      final userModel = await userService.getUserByUid(uid);
      if (userCredential.user?.email == 'admin@gmail.com') {
        emit(AuthAdmin());
      }

      if (userModel == null) {
        emit(AuthFailure("Không tìm thấy thông tin người dùng"));
        return;
      }

        emit(AuthSuccess("Đăng nhập thành công", userModel.uid));

    } catch (e) {
      emit(AuthFailure("Lỗi đăng nhập: ${e.toString()}"));
    }
  }


  // Đăng xuất
  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    emit(AuthInitial());
  }
}
