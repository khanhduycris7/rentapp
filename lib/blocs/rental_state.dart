import 'package:equatable/equatable.dart';

abstract class RentalState extends Equatable {
  const RentalState();

  @override
  List<Object> get props => [];
}

class RentalInitial extends RentalState {}

class RentalLoading extends RentalState {}

class RentalSuccess extends RentalState {
  final Map<String, dynamic> rentalData;

  const RentalSuccess({required this.rentalData});
}


class RentalFailure extends RentalState {
  final String error;

  const RentalFailure(this.error);

  @override
  List<Object> get props => [error];
}
