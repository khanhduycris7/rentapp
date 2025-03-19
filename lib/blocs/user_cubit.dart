import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';

// State
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final String name;
  final String email;

  UserLoaded({required this.name, required this.email});
}

class UserFailure extends UserState {
  final String error;

  const UserFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// Cubit
class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchUserInfo() async {
    emit(UserLoading());

    try {
      final user = _auth.currentUser;

      final userDoc = await _firestore.collection('users').doc(user?.uid).get();
      final userInfo = userDoc.data();

      if (!userDoc.exists) {
        emit(const UserFailure('Không tìm thấy thông tin người dùng.'));
        return;
      }

      emit(UserLoaded(
        name: userInfo?['fullName'],
        email: userInfo?['email'],
      ));
    } catch (e) {
      emit(UserFailure(e.toString()));
    }
  }
}
