import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ini palet warna yang udah aku pilih biar keliatan profesional tapi tetep enak diliat
  static const Color primary = Color(0xFF5B7C99); // biru abu-abu yang soft
  static const Color secondary = Color(0xFF7FA99B); // hijau sage yang kalem
  static const Color accent = Color(0xFFE8A87C); // terracotta hangat
  static const Color background = Color(0xFFF8F9FA); // abu-abu super terang
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color error = Color(0xFFE74C3C);
  static const Color success = Color(0xFF27AE60);
}

class AppStyles {
  static TextStyle get title => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  
  static TextStyle get header => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  
  static TextStyle get buttonText => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.3,
  );

  static InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: AppColors.surface,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
  
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: const Color.fromRGBO(0, 0, 0, 0.04),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
