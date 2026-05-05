import 'package:and_another_one/core/audio/home_bgm_route_mixin.dart';
import 'package:and_another_one/shared/widgets/music_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/auth_input_field.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../shared/widgets/game_menu_background.dart';
import '../../data/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>  with RouteAware, HomeBgmRouteMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    debugPrint('LOGIN initState fired');
  }

  bool _hasShownRouteMessage = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_hasShownRouteMessage) return;

    final message = ModalRoute.of(context)?.settings.arguments as String?;

    if (message != null && message.isNotEmpty) {
      _hasShownRouteMessage = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      });
    }
  }

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your username and password.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.loginWithUsername(
        username: username,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.home,
        arguments: 'Welcome back, $username!',
      );

    } on FirebaseAuthException catch (e) {
      String message = 'Login failed.';

      if (e.code == 'user-not-found') {
        message = 'Username not found.';
      } else if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'Incorrect username or password.';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double btnGap = 8;

    return Scaffold(
      body: GameMenuBackground(
        backgroundColor: AppColors.blueBg,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                children: [
                  Image.asset(
                    AppAssets.homeLogo,
                    width: size.width * 0.65,
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'LOGIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AuthInputField(
                          label: 'USERNAME',
                          hintText: 'Enter username',
                          controller: _usernameController,
                        ),
                        const SizedBox(height: 16),
                        AuthInputField(
                          label: 'PASSWORD',
                          hintText: 'Enter password',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        BeveledMenuButton(
                          label: 'LOGIN',
                          color: AppColors.greenButton,
                          width: double.infinity,
                          height: 64,
                          textColor: Colors.white,
                          fontSize: 22,
                          onTap: _login,
                        ),
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          child: const Text(
                            "Don't have an account? Register",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),

                  const SizedBox(height: btnGap + 20),

                  MusicButton(size: size.width * 0.12),
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}