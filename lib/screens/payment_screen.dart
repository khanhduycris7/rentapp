import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/payment_cubit.dart';
import '../blocs/payment_state.dart'; // cập nhật path đúng

class PaymentScreen extends StatelessWidget {
  final String rentalId;
  final int amount; // tổng tiền thanh toán

  const PaymentScreen({Key? key, required this.rentalId, required this.amount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PaymentCubit>(
      create: (_) => PaymentCubit(),
      child: BlocListener<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state is PaymentLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          } else if (state is PaymentSuccess) {
            Navigator.popUntil(context, (route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thanh toán thành công!')),
            );
          } else if (state is PaymentFailure) {
            Navigator.pop(context); // pop loading
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Thanh toán thất bại: ${state.error}')),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Thanh toán'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Số tiền cần thanh toán: ${amount.toStringAsFixed(0)} VNĐ', style: const TextStyle(fontSize: 18)),

                const SizedBox(height: 24),

                ListTile(
                  leading: const Icon(Icons.account_balance_wallet),
                  title: const Text('Ví Momo'),
                  onTap: () {
                    context.read<PaymentCubit>().makePayment(
                      rentalId: rentalId,
                      amount: amount,
                      method: 'Momo',
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: const Text('Thẻ tín dụng'),
                  onTap: () {
                    context.read<PaymentCubit>().makePayment(
                      rentalId: rentalId,
                      amount: amount,
                      method: 'Credit Card',
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.account_balance),
                  title: const Text('Chuyển khoản ngân hàng'),
                  onTap: () {
                    context.read<PaymentCubit>().makePayment(
                      rentalId: rentalId,
                      amount: amount,
                      method: 'Bank Transfer',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


