import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/car.dart';
import 'car_form_dialog.dart';

class AdminCarManagerScreen extends StatefulWidget {
  @override
  _AdminCarManagerScreenState createState() => _AdminCarManagerScreenState();
}

class _AdminCarManagerScreenState extends State<AdminCarManagerScreen> {
  List<Car> cars = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    setState(() => isLoading = true);

    final snapshot = await FirebaseFirestore.instance.collection('cars').get();

    final loadedCars = snapshot.docs.map((doc) {
      final data = doc.data();
      return Car.fromMap(data);
    }).toList();

    setState(() {
      cars = loadedCars;
      isLoading = false;
    });
  }

  Future<void> _addOrUpdateCar(Car car) async {
    final carIdStr = car.id.toString();

    try {
      final docRef = FirebaseFirestore.instance.collection('cars').doc(carIdStr);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update(car.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật xe thành công (ID: $carIdStr)')),
        );
      } else {
        await docRef.set(car.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thêm xe thành công (ID: $carIdStr)')),
        );
      }

      _loadCars();
    } catch (e) {
      print('Lỗi khi thêm/cập nhật xe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi thêm/cập nhật xe')),
      );
    }
  }

  Future<void> updateRentals(Car car) async {
    final carIdStr = car.id.toString();
    final docRef = FirebaseFirestore.instance.collection('rentals').doc(carIdStr);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      await docRef.update({'status': car.status});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật rentals thành công')),
      );
    }
  }

  Future<void> _deleteCar(int carId) async {
    final carIdStr = carId.toString();

    await FirebaseFirestore.instance.collection('cars').doc(carIdStr).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Xóa xe thành công (ID: $carIdStr)')),
    );

    _loadCars();
  }

  void _openCarForm({Car? car}) {
    showDialog(
      context: context,
      builder: (_) => CarFormDialog(
        car: car,
        onSaved: (savedCar) {
          _addOrUpdateCar(savedCar);
          updateRentals(savedCar);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCarForm(),
        icon: Icon(Icons.add),
        label: Text('Thêm xe'),
        backgroundColor: Colors.blue.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : cars.isEmpty
          ? Center(child: Text('Không có xe nào', style: TextStyle(color: Colors.grey, fontSize: 16)))
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: cars.length,
          itemBuilder: (context, index) {
            final car = cars[index];
            return _buildCarCard(car);
          },
        ),
      ),
    );
  }

  Widget _buildCarCard(Car car) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      shadowColor: Colors.blue.withOpacity(0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _openCarForm(car: car),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildCarImage(car.image),
              SizedBox(width: 16),
              Expanded(
                child: _buildCarInfo(car),
              ),
              _buildCarActions(car),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageUrl.isNotEmpty
          ? Image.network(
        imageUrl,
        width: 100,
        height: 80,
        fit: BoxFit.cover,
      )
          : Container(
        width: 100,
        height: 80,
        color: Colors.blue.shade100,
        child: Icon(Icons.directions_car, size: 40, color: Colors.blue.shade600),
      ),
    );
  }

  Widget _buildCarInfo(Car car) {
    Color statusColor = car.status == 'Đang chờ duyệt'
        ? Colors.orange
        : car.status == 'Cho thuê'
        ? Colors.green
        : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${car.model}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
        ),
        SizedBox(height: 6),
        Text('ID: ${car.id}', style: TextStyle(fontSize: 13, color: Colors.grey)),
        SizedBox(height: 4),
        Text('Giá: ${car.pricePerHour} VND/h',
            style: TextStyle(fontSize: 14, color: Colors.blue.shade800)),
        SizedBox(height: 6),
        Chip(
          label: Text(car.status),
          backgroundColor: statusColor.withOpacity(0.1),
          labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          shape: StadiumBorder(side: BorderSide(color: statusColor)),
        ),
      ],
    );
  }

  Widget _buildCarActions(Car car) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.blue.shade600),
          onPressed: () => _openCarForm(car: car),
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red.shade600),
          onPressed: () => _confirmDeleteCar(car.id),
        ),
      ],
    );
  }

  void _confirmDeleteCar(int carId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Xác nhận xóa xe', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc muốn xóa xe có ID $carId không?'),
        actions: [
          TextButton(
            child: Text('Hủy', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Xóa'),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCar(carId);
            },
          ),
        ],
      ),
    );
  }
}

