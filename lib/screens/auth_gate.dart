import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/user_services.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'onboarding_alias_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Widget> decideScreen() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    final appUser = await UserService().getCurrentUserData();

    if (appUser == null ||
        appUser.profileCompleted == false ||
        appUser.artistAlias.trim().isEmpty) {
      return const OnboardingAliasScreen();
    }

    return const HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: decideScreen(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            ),
          );
        }

        return snapshot.data!;
      },
    );
  }
}