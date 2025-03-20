
import 'package:demo_rentapp/screens/rent_car_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/rental_cubit.dart';
import '../models/car.dart';
import 'dart:io';

import '../models/user.dart';
import '../services/user_service.dart';

class CarDetailScreen extends StatefulWidget {
  final Car car;
  final UserModel userModel;

  const CarDetailScreen({Key? key, required this.car, required this.userModel}) : super(key: key);

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {

  final userService = UserService();
  late UserModel currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.userModel;
  }

  Future<void> _updateCurrentUser() async {
    final updatedUser = await userService.getUserByUid(widget.userModel.uid);
    setState(() {
      currentUser = updatedUser!;
      print(currentUser.driverLicenseImagePath);
    });
  }
  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern('vi');
    final formattedPrice = formatter.format(widget.car.pricePerHour);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar có hiệu ứng scroll
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.car.model, style: const TextStyle(color: Colors.white)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.car.image,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSlider(widget.car.images),
                  const SizedBox(height: 20),
                  _buildInfoSection(widget.car, formattedPrice),
                  const SizedBox(height: 30),
                  _buildRentButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSlider(List<String> images) {
    if (images.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hình ảnh chi tiết',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: images.length,
            controller: PageController(viewportFraction: 0.8),
            itemBuilder: (context, index) {
              final imageUrl = images[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: imageUrl.startsWith('http')
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : Image.file(File(imageUrl), fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(Car car, String formattedPrice) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.directions_car, 'Tên xe', car.model),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.local_gas_station, 'Dung tích nhiên liệu', car.fuelCapacity),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.speed, 'Km đã đi', car.distance.toString()),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.attach_money, 'Giá thuê', '$formattedPrice VNĐ/ngày'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.verified_user, 'Tình trạng', car.codition),
            const SizedBox(height: 12),
            _buildStatusBadge(car.status),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'Cho thuê':
        color = Colors.redAccent;
        text = 'Đã cho thuê';
        break;
      case 'Đang chờ duyệt':
        color = Colors.orange;
        text = 'Chờ duyệt';
        break;
      case 'Bảo trì':
        color = Colors.grey;
        text = 'Đang bảo trì';
        break;
      default:
        color = Colors.green;
        text = 'Sẵn sàng';
    }

    return Row(
      children: [
        const Icon(Icons.info_outline, color: Colors.black54),
        const SizedBox(width: 10),
        Chip(
          label: Text(text),
          backgroundColor: color.withOpacity(0.2),
          labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRentButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          await _updateCurrentUser();
          if (widget.car.status == "Cho thuê") {
            _showSnackBar(context, "Xe đã được cho thuê, vui lòng chọn xe khác!");
          } else if (widget.car.status == "Đang chờ duyệt") {
            _showSnackBar(context, "Xe đang chờ duyệt, vui lòng đợi trong giây lát!");
          } else if (widget.car.status == "Bảo trì") {
            _showSnackBar(context, "Xe đang bảo trì, vui lòng chọn xe khác!");
          } else if((currentUser.driverLicenseImagePath.isEmpty || currentUser.idCardImagePath.isEmpty)){
            _showSnackBar(context, "Hãy cập nhật đăng kí xe và căn cước công dân trước khi thuê xe");
          }else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (_) => RentalCubit(),
                  child: RentCarScreen(
                    price: widget.car.pricePerHour,
                    carId: widget.car.id.toString(),
                    carModel: widget.car.model,
                  ),
                ),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.blueAccent,
          elevation: 4,
        ),
        child: const Text(
          'Thuê xe ngay',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

