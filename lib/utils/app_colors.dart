import 'package:flutter/material.dart';

// Minimalist, chic color scheme - White, Beige, Black
class AppColors {
  // Primary Colors
  static const white = Color(0xFFFAFAFA); // Off-white
  static const cream = Color(0xFFF5F1E8); // Warm cream
  static const beige = Color(0xFFE8DCC4); // Light beige
  static const darkBeige = Color(0xFFD4C5B0); // Darker beige
  static const charcoal = Color(0xFF2C2C2C); // Soft black
  static const black = Color(0xFF1A1A1A); // True black
  
  // Accent
  static const warmAccent = Color(0xFFC9A77C); // Warm tan/gold
  static const mutedGreen = Color(0xFF8B9D83); // Muted sage green for success
  
  // Text Colors
  static const textPrimary = charcoal;
  static const textSecondary = Color(0xFF666666);
  static const textHint = Color(0xFF999999);
  static const textInverse = white;
  
  // Backgrounds
  static const bgPrimary = white;
  static const bgSecondary = cream;
  static const bgCard = beige;
  
  // Status Colors
  static const success = mutedGreen;
  static const warning = Color(0xFFD4A574); // Warm orange-beige
  static const error = Color(0xFFB88B8B); // Muted red-brown
  
  // Gradients - Subtle and elegant
  static const mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [cream, white],
  );
  
  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [beige, darkBeige],
  );
  
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warmAccent, darkBeige],
  );
}
