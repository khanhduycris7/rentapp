import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../models/contract_model.dart';


class MyContractsScreen extends StatefulWidget {
  @override
  _MyContractsScreenState createState() => _MyContractsScreenState();
}

class _MyContractsScreenState extends State<MyContractsScreen> {
  List<ContractModel> contracts = [];
  bool isLoading = true;
  final Color primaryColor = Colors.blue; // Đồng bộ với các màn hình khác

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  Future<void> _loadContracts() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa đăng nhập!')),
      );
      setState(() => isLoading = false);
      return;
    }

    final data = await getContractsByUserId(user.uid);
    print('Đang đăng nhập bằng email: ${user.email}');

    setState(() {
      contracts = data;
      isLoading = false;
    });
  }

  Future<List<ContractModel>> getContractsByUserId(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('contracts').get();
      final contract = snapshot.docs
          .map((doc) => ContractModel.fromMap(doc.data(), doc.id))
          .where((contract) => contract.userId == userId)
          .toList();
      return contract;
    } catch (e) {
      print('Lỗi khi lấy contracts: $e');
      return [];
    }
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hợp Đồng Của Tôi', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : contracts.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Bạn chưa có hợp đồng nào.',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: contracts.length,
          itemBuilder: (context, index) => _buildContractCard(contracts[index]),
        ),
      ),
    );
  }

  Widget _buildContractCard(ContractModel contract) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.assignment_turned_in, color: Colors.blue, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    contract.carModel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1, color: Colors.grey),
            _buildInfoRow(Icons.person, 'Tên khách hàng', contract.userName),
            _buildInfoRow(Icons.phone, 'Số điện thoại', contract.userPhone),
            _buildInfoRow(Icons.calendar_today, 'Ngày thuê', _formatDate(contract.rentDate)),
            _buildInfoRow(Icons.timer, 'Thời gian thuê', '${contract.rentDurationHours} ngày'),
            _buildInfoRow(Icons.location_on, 'Địa điểm nhận', contract.pickupLocation),
            if (contract.note.isNotEmpty)
              _buildInfoRow(Icons.note_alt, 'Ghi chú', contract.note),
            const SizedBox(height: 12),
            _buildStatusRow(contract.status),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.date_range, 'Ngày tạo', _formatDate(contract.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '$label: ',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String status) {
    Color statusColor = status == 'Đang xử lý'
        ? Colors.orange
        : status == 'Đã duyệt'
        ? Colors.green
        : Colors.red;

    return Row(
      children: [
        Icon(Icons.info, size: 20, color: statusColor),
        const SizedBox(width: 12),
        Text(
          'Trạng thái: ',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
