
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/contract_cubit.dart';



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'car_list_screen.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContractScreen extends StatefulWidget {
  final Map<String, dynamic> rentalData;

  const ContractScreen({super.key, required this.rentalData});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  bool isAgree = false;
  String paymentMethod = 'Tiền mặt';
  String? selectedVoucher;
  double discountAmount = 0;

  final List<Map<String, dynamic>> vouchers = [
    {
      'code': 'SALE10',
      'description': 'Giảm 10% cho đơn thuê',
      'discountPercent': 10,
    },
    {
      'code': 'SALE500K',
      'description': 'Giảm 500.000 VND',
      'discountValue': 500000,
    },
    {
      'code': 'FREESHIP',
      'description': 'Giảm 300.000 VND cho phí giao xe',
      'discountValue': 300000,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContractCubit>(
      create: (context) => ContractCubit(),
      child: BlocListener<ContractCubit, ContractState>(
        listener: (context, state) {
          if (state is ContractLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          } else if (state is ContractSigned) {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CarListScreen()),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ký hợp đồng thành công!')),
            );
          } else if (state is ContractFailure) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi ký hợp đồng: ${state.error}')),
            );
          }
        },
        child: WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Hợp Đồng Thuê Xe'),
              elevation: 0,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade50, Colors.white],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: _contractDetail(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _contractDetail(BuildContext context) {
    final rental = widget.rentalData;
    double originalPrice = rental['price'].toDouble();
    double finalPrice = (originalPrice - discountAmount).clamp(0, double.infinity);
    final formatter = NumberFormat.decimalPattern('vi');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HỢP ĐỒNG THUÊ XE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.person, 'Tên khách hàng', rental['userName']),
                _buildInfoRow(Icons.phone, 'Số điện thoại', rental['userPhone']),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.directions_car, 'Xe thuê', rental['carModel']),
                _buildInfoRow(Icons.confirmation_number, 'Mã xe', rental['carId']),
                _buildInfoRow(Icons.calendar_today, 'Ngày thuê', rental['rentDate'].toString()),
                _buildInfoRow(Icons.timer, 'Thời gian thuê', '${rental['rentDurationHours']} Ngày'),
                const SizedBox(height: 12),
                _buildPriceInfo(formatter.format(finalPrice), formatter.format(discountAmount)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Điều khoản hợp đồng',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildTerm('1. Khách hàng cam kết sử dụng xe đúng mục đích.'),
                _buildTerm('2. Khách hàng chịu trách nhiệm bảo quản xe.'),
                _buildTerm('3. Trả xe đúng thời hạn và tình trạng ban đầu.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        CheckboxListTile(
          value: isAgree,
          onChanged: (val) => setState(() => isAgree = val!),
          title: const Text('Tôi đồng ý với các điều khoản trong hợp đồng'),
          activeColor: Colors.blue,
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        const SizedBox(height: 16),
        _buildSelectionRow(
          icon: Icons.payment,
          title: 'Phương thức thanh toán',
          value: paymentMethod,
          onTap: _showPaymentOptions,
        ),
        const SizedBox(height: 16),
        _buildSelectionRow(
          icon: Icons.local_offer,
          title: 'Voucher',
          value: selectedVoucher ?? 'Chưa chọn',
          onTap: _showVoucherOptions,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isAgree
                ? () {
              final newRentalData = {
                ...widget.rentalData,
                'price': finalPrice,
              };
              context.read<ContractCubit>().signContract(newRentalData, paymentMethod);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CarListScreen()),
              );
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: const Text(
              'Ký Hợp Đồng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text('$label: $value', style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(String finalPrice, String discountAmountFormatted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.attach_money, color: Colors.green),
            const SizedBox(width: 12),
            Text(
              'Giá tiền: $finalPrice VND',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        if (discountAmount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Đã giảm: $discountAmountFormatted VND (Voucher: $selectedVoucher)',
              style: const TextStyle(fontSize: 14, color: Colors.redAccent),
            ),
          ),
      ],
    );
  }

  Widget _buildTerm(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildSelectionRow({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(value),
        trailing: const Icon(Icons.arrow_drop_down, color: Colors.blue),
        onTap: onTap,
      ),
    );
  }

  void _showPaymentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return _buildBottomSheet([
          _buildPaymentOption(Icons.money, 'Tiền mặt'),
          _buildPaymentOption(Icons.account_balance_wallet, 'ZaloPay'),
          _buildPaymentOption(Icons.phone_android, 'Momo'),
          _buildPaymentOption(Icons.account_balance, 'Ngân hàng'),
        ]);
      },
    );
  }

  void _showVoucherOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return _buildBottomSheet(
          vouchers.map((voucher) {
            return ListTile(
              leading: const Icon(Icons.local_offer, color: Colors.blue),
              title: Text(voucher['code']),
              subtitle: Text(voucher['description']),
              onTap: () {
                double originalPrice = widget.rentalData['price'].toDouble();
                double discount = voucher.containsKey('discountPercent')
                    ? (voucher['discountPercent'] / 100) * originalPrice
                    : voucher['discountValue'].toDouble();
                setState(() {
                  selectedVoucher = voucher['code'];
                  discountAmount = discount;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPaymentOption(IconData icon, String method) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(method),
      onTap: () {
        setState(() => paymentMethod = method);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildBottomSheet(List<Widget> children) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          height: 4,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }
}


