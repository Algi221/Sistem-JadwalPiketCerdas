import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'student/student_dashboard.dart';
import 'teacher/teacher_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _nipdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // background animasi kotak-kotak yang banyak!
          AnimatedBackground(animation: _animationController),
          
          // konten login
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                decoration: AppStyles.cardDecoration.copyWith(
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.12),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(40.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Jadwal Piket Cerdas',
                        textAlign: TextAlign.center,
                        style: AppStyles.title.copyWith(fontSize: 26),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'SMA Yadika 11 - Kelas 11-J',
                        textAlign: TextAlign.center,
                        style: AppStyles.body,
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: _nipdController,
                        style: AppStyles.body.copyWith(color: AppColors.textPrimary),
                        decoration: AppStyles.inputDecoration('NIPD', Icons.person_outline),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Harap masukkan NIPD';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        style: AppStyles.body.copyWith(color: AppColors.textPrimary),
                        decoration: AppStyles.inputDecoration('Password', Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Harap masukkan Password';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      Consumer<AuthProvider>(
                        builder: (context, auth, child) {
                          return SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : () => _handleLogin(auth),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text('Masuk', style: AppStyles.buttonText),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin(AuthProvider auth) async {
    if (_formKey.currentState!.validate()) {
      final success = await auth.login(
        _nipdController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        if (auth.currentUser!.role == 'guru') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TeacherDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboard()),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login Gagal. Periksa NIPD & Password.', style: AppStyles.body.copyWith(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }
}

// widget animasi background kotak-kotak
class AnimatedBackground extends AnimatedWidget {
  const AnimatedBackground({super.key, required Animation<double> animation})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return CustomPaint(
      painter: FloatingSquaresPainter(animation.value),
      size: Size.infinite,
    );
  }
}

// painter buat gambar kotak-kotak yang bergerak
class FloatingSquaresPainter extends CustomPainter {
  final double animationValue;
  final Random random = Random(42); // seed tetap biar konsisten

  FloatingSquaresPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // background gradient yang smooth
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.background,
        AppColors.primary.withOpacity(0.05),
        AppColors.secondary.withOpacity(0.05),
      ],
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // gambar 40 kotak-kotak yang bergerak dengan variasi!
    for (int i = 0; i < 40; i++) {
      final paint = Paint()
        ..color = _getColor(i).withOpacity(0.12 + (i % 3) * 0.03)
        ..style = PaintingStyle.fill;

      // variasi ukuran kotak
      final squareSize = 30.0 + (random.nextDouble() * 80);
      
      // variasi kecepatan gerak
      final speedX = 30 + (i % 5) * 15.0;
      final speedY = 20 + (i % 4) * 10.0;
      
      // posisi kotak yang bergerak
      final x = (random.nextDouble() * size.width + animationValue * speedX) % (size.width + squareSize);
      final y = (random.nextDouble() * size.height + animationValue * speedY) % (size.height + squareSize);
      
      // rotasi yang berbeda-beda
      final rotation = animationValue * 2 * pi * (i % 2 == 0 ? 1 : -1) * (0.3 + (i % 3) * 0.2);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      
      // variasi bentuk: kotak solid atau outline
      if (i % 3 == 0) {
        // kotak dengan border aja (outline)
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: squareSize, height: squareSize),
            Radius.circular(squareSize * 0.25),
          ),
          Paint()
            ..color = _getColor(i).withOpacity(0.2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      } else {
        // kotak solid (warna penuh)
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: squareSize, height: squareSize),
            Radius.circular(squareSize * 0.2),
          ),
          paint,
        );
      }
      
      canvas.restore();
    }
  }

  Color _getColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
    ];
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(FloatingSquaresPainter oldDelegate) => true;
}
