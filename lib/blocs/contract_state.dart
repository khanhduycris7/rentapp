part of 'contract_cubit.dart';

abstract class ContractState extends Equatable {
  const ContractState();

  @override
  List<Object> get props => [];
}

class ContractInitial extends ContractState {}

class ContractLoading extends ContractState {}

class ContractSigned extends ContractState {}

class ContractFailure extends ContractState {
  final String error;

  const ContractFailure(this.error);

  @override
  List<Object> get props => [error];
}
