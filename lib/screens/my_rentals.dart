import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_rentapp/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/rental_model.dart';

class MyRentalsScreen extends StatefulWidget {
  MyRentalsScreen({super.key, required this.userModel});
  UserModel userModel;

  @override
  State<MyRentalsScreen> createState() => _MyRentalsScreenState();
}

class _MyRentalsScreenState extends State<MyRentalsScreen> {
  List<RentalModel> rentals = [];
  bool isLoading = true;
  final Color primaryColor = Colors.green; // Đồng bộ với các màn hình khác

  @override
  void initState() {
    super.initState();
    _loadRentals();
  }

  Future<void> _loadRentals() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa đăng nhập!')),
      );
      setState(() => isLoading = false);
      return;
    }

    final data = await getRentalsByUserId(user.uid);

    print('Đang đăng nhập bằng email: ${user.email}');
    setState(() {
      rentals = data;
      isLoading = false;
    });
  }

  Future<List<RentalModel>> getRentalsByUserId(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('rentals').get();
      final rentals = snapshot.docs
          .map((doc) => RentalModel.fromMap(doc.data(), doc.id))
          .where((rental) => rental.userId == userId)
          .toList();
      return rentals;
    } catch (e) {
      print('Lỗi khi lấy rentals: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Thuê Xe', style: TextStyle(color: Colors.white)),
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
        iconTheme: const IconThemeData(color: Colors.white),
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
            : rentals.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.car_rental, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Bạn chưa thuê xe nào.',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: rentals.length,
          itemBuilder: (context, index) => _buildRentalCard(rentals[index]),
        ),
      ),
    );
  }

  Widget _buildRentalCard(RentalModel rental, ) {
    final formatter = NumberFormat.decimalPattern('vi');
    final formattedPrice = formatter.format(rental.price);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.car_rental, color: Colors.blue, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rental.carModel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.calendar_today, 'Ngày thuê', _formatDate(rental.rentDate)),
                  _buildInfoRow(Icons.access_time, 'Thời gian thuê', '${rental.rentDurationHours} ngày'),
                  _buildInfoRow(Icons.location_on, 'Địa điểm nhận', rental.pickupLocation),
                  const SizedBox(height: 12),
                  _buildStatusBadge(rental.status, widget.userModel),
                  const SizedBox(height: 12),
                  Text(
                    'Giá thuê: $formattedPrice VNĐ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, UserModel userModel) {
    Color bgColor = status == 'Đang chờ duyệt' ? Colors.red : status != 'Sẵn sàng cho thuê' ? primaryColor : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bgColor),
      ),
      child: Text(
        status != 'Sẵn sàng cho thuê' ? status : 'Đang chờ duyệt',
        style: TextStyle(
          color: bgColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
}


//
// class MyRentalsScreen extends StatefulWidget {
//   MyRentalsScreen({Key? key}) : super(key: key);
//
//   @override
//   _MyRentalsScreenState createState() => _MyRentalsScreenState();
// }
//
// class _MyRentalsScreenState extends State<MyRentalsScreen> {
//   List<RentalModel> rentals = [];
//   bool isLoading = true;
//   final Color primaryColor = Colors.blue; // Đồng bộ với các màn hình khác
//
//   @override
//   void initState() {
//     super.initState();
//     _loadRentals();
//   }
//
//   Future<void> _loadRentals() async {
//     final user = FirebaseAuth.instance.currentUser;
//
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Bạn chưa đăng nhập!')),
//       );
//       setState(() => isLoading = false);
//       return;
//     }
//
//     final data = await getRentalsByUserId(user.uid);
//
//     print('Đang đăng nhập bằng email: ${user.email}');
//     setState(() {
//       rentals = data;
//       isLoading = false;
//     });
//   }
//
//   Future<List<RentalModel>> getRentalsByUserId(String userId) async {
//     try {
//       final snapshot = await FirebaseFirestore.instance.collection('rentals').get();
//       final rentals = snapshot.docs
//           .map((doc) => RentalModel.fromMap(doc.data(), doc.id))
//           .where((rental) => rental.userId == userId)
//           .toList();
//       return rentals;
//     } catch (e) {
//       print('Lỗi khi lấy rentals: $e');
//       return [];
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Lịch Sử Thuê Xe', style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: primaryColor,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [primaryColor, Colors.blueAccent],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.blue.shade50, Colors.white],
//           ),
//         ),
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator(color: Colors.blue))
//             : rentals.isEmpty
//             ? Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.car_rental, size: 60, color: Colors.grey.shade400),
//               const SizedBox(height: 16),
//               Text(
//                 'Bạn chưa thuê xe nào.',
//                 style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
//               ),
//             ],
//           ),
//         )
//             : ListView.builder(
//           padding: const EdgeInsets.all(16.0),
//           itemCount: rentals.length,
//           itemBuilder: (context, index) => _buildRentalCard(rentals[index]),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRentalCard(RentalModel rental, ) {
//     final formatter = NumberFormat.decimalPattern('vi');
//     final formattedPrice = formatter.format(rental.price);
//
//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: primaryColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: const EdgeInsets.all(12),
//               child: const Icon(Icons.car_rental, color: Colors.blue, size: 32),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     rental.carModel,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   _buildInfoRow(Icons.calendar_today, 'Ngày thuê', _formatDate(rental.rentDate)),
//                   _buildInfoRow(Icons.access_time, 'Thời gian thuê', '${rental.rentDurationHours} ngày'),
//                   _buildInfoRow(Icons.location_on, 'Địa điểm nhận', rental.pickupLocation),
//                   const SizedBox(height: 12),
//                   _buildStatusBadge(rental.status),
//                   const SizedBox(height: 12),
//                   Text(
//                     'Giá thuê: $formattedPrice VNĐ',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         children: [
//           Icon(icon, size: 16, color: Colors.grey),
//           const SizedBox(width: 8),
//           Text(
//             '$label: ',
//             style: const TextStyle(fontSize: 14, color: Colors.grey),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 14),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatusBadge(String status) {
//     Color bgColor = status == 'Đang chờ duyệt' ? Colors.orange : primaryColor;
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: bgColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: bgColor),
//       ),
//       child: Text(
//         status,
//         style: TextStyle(
//           color: bgColor,
//           fontWeight: FontWeight.w600,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }
//
//   String _formatDate(DateTime date) {
//     return "${date.day.toString().padLeft(2, '0')}/"
//         "${date.month.toString().padLeft(2, '0')}/"
//         "${date.year}";
//   }
// }
