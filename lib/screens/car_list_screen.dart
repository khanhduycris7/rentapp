
import 'package:demo_rentapp/screens/rent_car_screen.dart';
import 'package:demo_rentapp/screens/user_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/auth_cubit.dart';
import '../blocs/car_cubit.dart';
import '../blocs/rental_cubit.dart';
import '../models/car.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'admin/admin_car_manager.dart';
import 'car_detail.dart';
import 'login_screen.dart';
import 'my_contract.dart';
import 'my_rentals.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({Key? key}) : super(key: key);

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  UserModel? userModel;
  final userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _fetchUserInfo();
    super.initState();
  }

  Future<void> _fetchUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      final fetchedUser = await userService.getUserByUid(userId);
      if (fetchedUser != null) {
        setState(() {
          userModel = fetchedUser;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CarCubit()..fetchCars()),
        BlocProvider(create: (_) => AuthCubit(FirebaseAuth.instance)),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title:  Text(userModel?.email != "phatadmin@gmail.com" ? 'Thuê Xe' : 'Quản lý xe', style: TextStyle(color: Colors.white)),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          drawer: _buildDrawer(context),
          body: userModel?.email != "phatadmin@gmail.com" ? Column(
            children: [
              _buildSearchBar(),
              Expanded(child: _buildCarList()),
            ],
          ) : AdminCarManagerScreen()
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(userModel?.fullName ?? 'Tên người dùng', style: const TextStyle(fontSize: 18)),
            accountEmail: Text(userModel?.email ?? 'Email người dùng'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userModel != null ? userModel!.fullName[0].toUpperCase() : 'A',
                style: const TextStyle(fontSize: 30, color: Colors.green),
              ),
            ),
          ),
          userModel?.email != "phatadmin@gmail.com" ? ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Trang cá nhân'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const UserInfoScreen()));
            },
          ) : SizedBox.shrink(),
          userModel?.email != "phatadmin@gmail.com" ? ListTile(
            leading: const Icon(Icons.car_rental),
            title: const Text('Xe đã thuê'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyRentalsScreen(userModel: userModel!,)));
            },
          ) : SizedBox.shrink(),
          userModel?.email != "phatadmin@gmail.com" ? ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Hợp đồng'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyContractsScreen()));
            },
          ) : SizedBox.shrink(),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Đăng xuất'),
            onTap: () {
              context.read<AuthCubit>().logout();
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm xe...',
          prefixIcon: const Icon(Icons.search, color: Colors.teal),
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        onChanged: (value) {
          setState(() {
            searchText = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildCarList() {
    return BlocBuilder<CarCubit, CarState>(
      builder: (context, state) {
        if (state is CarLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CarLoaded) {
          final filteredCars = state.cars.where((car) => car.model.toLowerCase().contains(searchText)).toList();

          if (filteredCars.isEmpty) {
            return const Center(child: Text('Không tìm thấy xe nào!', style: TextStyle(fontSize: 16)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredCars.length,
            itemBuilder: (context, index) {
              final car = filteredCars[index];
              return _buildCarCard(car);
            },
          );
        } else if (state is CarError) {
          return Center(child: Text('Đã xảy ra lỗi: ${state.message}'));
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCarCard(Car car) {
    final formatter = NumberFormat.decimalPattern('vi');
    final formattedPrice = formatter.format(car.pricePerHour);

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailScreen(car: car)));
      },
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  car.image,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                car.model,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.speed, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('Công suất: ${car.fuelCapacity}'),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.money, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('Giá: $formattedPrice VNĐ/ngày', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.av_timer, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('Số km đã đi: ${car.distance} km'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
