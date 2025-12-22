// --- Glass Pill Widget ---

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassPill extends StatelessWidget {
  final String text;
  final bool isSmall;

  const GlassPill({super.key, required this.text, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 12 : 20,
            vertical: isSmall ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4), // Darker premium glass
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(
                0xFFD4AF37,
              ).withValues(alpha: 0.3), // Gold border
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: isSmall ? 12 : 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
