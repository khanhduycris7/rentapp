import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car.dart';

part 'car_state.dart';

class CarCubit extends Cubit<CarState> {
  CarCubit() : super(CarInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy danh sách xe từ collection cars
  Future<void> fetchCars() async {
    emit(CarLoading());
    try {
      var snapshot = await _firestore.collection('cars').get();
      final cars = snapshot.docs.map((doc) {
        final data = doc.data();
        return Car.fromMap(data);
      }).toList();

      emit(CarLoaded(cars));
    } catch (e) {
      emit(CarError(e.toString()));
    }
  }
}
