import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/car.dart';

class CarFormDialog extends StatefulWidget {
  final Car? car;
  final Function(Car) onSaved;

  CarFormDialog({this.car, required this.onSaved});

  @override
  _CarFormDialogState createState() => _CarFormDialogState();
}
class _CarFormDialogState extends State<CarFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController idController;
  late TextEditingController modelController;
  late TextEditingController distanceController;
  late TextEditingController fuelCapacityController;
  late TextEditingController pricePerHourController;
  late TextEditingController imageController;

  final List<String> conditionOptions = ['Mới', 'Đã qua sử dụng'];
  final List<String> statusOptions = ['Sẵn sàng cho thuê', 'Cho thuê', 'Bảo trì'];

  late String selectedCondition;
  late String selectedStatus;

  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = [];

  @override
  void initState() {
    super.initState();
    final car = widget.car;

    idController = TextEditingController(text: car?.id.toString() ?? '');
    modelController = TextEditingController(text: car?.model ?? '');
    distanceController = TextEditingController(text: car?.distance.toString() ?? '');
    fuelCapacityController = TextEditingController(text: car?.fuelCapacity ?? '');
    pricePerHourController = TextEditingController(text: car?.pricePerHour.toString() ?? '');
    imageController = TextEditingController(text: car?.image ?? '');

    selectedCondition = conditionOptions.contains(car?.codition) ? car!.codition : conditionOptions[0];
    selectedStatus = statusOptions.contains(car?.status) ? car!.status : statusOptions[0];
  }

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          selectedImages = images.take(4).toList();
        });
      }
    } catch (e) {
      print("Lỗi chọn ảnh: $e");
    }
  }

  void _saveCar() {
    if (!_formKey.currentState!.validate()) return;

    final List<String> imagePaths = selectedImages.map((file) => file.path).toList();

    final car = Car(
      id: int.parse(idController.text),
      model: modelController.text,
      distance: int.parse(distanceController.text),
      fuelCapacity: fuelCapacityController.text,
      pricePerHour: int.parse(pricePerHourController.text),
      codition: selectedCondition,
      status: selectedStatus,
      image: imageController.text,
      images: imagePaths,
    );

    widget.onSaved(car);
    Navigator.of(context).pop();
  }

  Widget _buildSelectedImages() {
    if (selectedImages.isEmpty) {
      return Text('Chưa chọn ảnh nào.');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: selectedImages.map((imageFile) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(imageFile.path),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedImages.remove(imageFile);
                  });
                },
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.blue.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.car == null ? 'Thêm xe mới' : 'Chỉnh sửa xe',
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// ID Xe
              TextFormField(
                controller: idController,
                decoration: _inputDecoration('ID xe'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nhập ID xe';
                  if (int.tryParse(value) == null) return 'ID phải là số';
                  return null;
                },
                enabled: widget.car == null,
              ),

              SizedBox(height: 12),

              /// Tên xe
              TextFormField(
                controller: modelController,
                decoration: _inputDecoration('Tên xe'),
                validator: (value) => value == null || value.isEmpty ? 'Nhập tên xe' : null,
              ),

              SizedBox(height: 12),

              /// Quãng đường
              TextFormField(
                controller: distanceController,
                decoration: _inputDecoration('Quãng đường đã chạy'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Nhập quãng đường' : null,
              ),

              SizedBox(height: 12),

              /// Dung tích nhiên liệu
              TextFormField(
                controller: fuelCapacityController,
                decoration: _inputDecoration('Dung tích nhiên liệu'),
                validator: (value) => value == null || value.isEmpty ? 'Nhập dung tích' : null,
              ),

              SizedBox(height: 12),

              /// Giá thuê/giờ
              TextFormField(
                controller: pricePerHourController,
                decoration: _inputDecoration('Giá thuê / giờ'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Nhập giá thuê' : null,
              ),

              SizedBox(height: 12),

              /// Dropdown Tình trạng
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Tình trạng'),
                value: selectedCondition,
                items: conditionOptions.map((String condition) {
                  return DropdownMenuItem<String>(
                    value: condition,
                    child: Text(condition),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCondition = newValue!;
                  });
                },
              ),

              SizedBox(height: 12),

              /// Dropdown Trạng thái
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Trạng thái'),
                value: selectedStatus,
                items: statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStatus = newValue!;
                  });
                },
              ),

              SizedBox(height: 12),

              /// URL ảnh đại diện
              TextFormField(
                controller: imageController,
                decoration: _inputDecoration('URL ảnh đại diện'),
                validator: (value) => value == null || value.isEmpty ? 'Nhập URL ảnh' : null,
              ),

              SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ảnh các góc nhìn khác:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),

              SizedBox(height: 8),

              _buildSelectedImages(),

              SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: pickImages,
                icon: Icon(Icons.add_a_photo, color: Colors.white,),
                label: Text('Chọn ảnh (tối đa 4)', style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Hủy'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            side: BorderSide(color: Colors.blue),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        ElevatedButton(
          onPressed: _saveCar,
          child: Text('Lưu', style: TextStyle(color: Colors.white),),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }
}




