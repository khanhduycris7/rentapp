import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../blocs/auth_cubit.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final fullNameController = TextEditingController();
    final phoneController = TextEditingController();
    final driverLicenseController = TextEditingController();
    final idCardController = TextEditingController();
    final addressController = TextEditingController();
    final dateOfBirthController = TextEditingController();

    return BlocProvider(
      create: (context) => AuthCubit(FirebaseAuth.instance),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text("Đăng ký"),
          backgroundColor: Colors.blue.shade700,
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              Navigator.pop(context);
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      'Đăng ký tài khoản',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Điền thông tin bên dưới để đăng ký',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),

                    _buildInputField(
                      controller: fullNameController,
                      hintText: "Họ và tên",
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: phoneController,
                      hintText: "Số điện thoại",
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: driverLicenseController,
                      hintText: "Số giấy phép lái xe",
                      icon: Icons.card_membership,
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: idCardController,
                      hintText: "Số CCCD",
                      icon: Icons.credit_card,
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: addressController,
                      hintText: "Địa chỉ",
                      icon: Icons.home,
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: dateOfBirthController,
                      hintText: "Ngày sinh (dd/mm/yyyy)",
                      icon: Icons.cake,
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: emailController,
                      hintText: "Email",
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: passwordController,
                      hintText: "Mật khẩu",
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                          context.read<AuthCubit>().register(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                            fullName: fullNameController.text.trim(),
                            phoneNumber: phoneController.text.trim(),
                            driverLicense:
                            driverLicenseController.text.trim(),
                            idCardNumber: idCardController.text.trim(),
                            address: addressController.text.trim(),
                            dateOfBirth:
                            dateOfBirthController.text.trim(),
                          );
                        },
                        child: state is AuthLoading
                            ? const CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                            : const Text(
                          "Đăng ký",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Bạn đã có tài khoản? Đăng nhập",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget helper để tái sử dụng Field UI giống LoginScreen
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue),
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
      ),
    );
  }
}




