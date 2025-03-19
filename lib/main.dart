
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_rentapp/screens/onboarding_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth_cubit.dart';
import 'blocs/contract_cubit.dart';
import 'blocs/payment_cubit.dart';
import 'blocs/user_cubit.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(FirebaseAuth.instance),
        ),
        BlocProvider(create: (_) => UserCubit()..fetchUserInfo()),
        BlocProvider<ContractCubit>(
          lazy: false,
          create: (context) => ContractCubit(),
        ),
        BlocProvider<PaymentCubit>(
          lazy: false,
          create: (context) => PaymentCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'Firebase Auth Bloc',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const OnboardingPage(),
      ),
    );
  }
}
