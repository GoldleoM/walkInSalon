import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_infinite_marquee/flutter_infinite_marquee.dart'
    as marquee;

class InfiniteMarquee extends StatelessWidget {
  final String text;
  final double speed;
  final double height;
  final Color? textColor;
  final bool active;

  const InfiniteMarquee({
    super.key,
    required this.text,
    this.speed = 40,
    this.height = 60,
    this.textColor,
    this.active = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!active) {
      // Return a static placeholder to avoid performance cost
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.oswald(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: textColor ?? Colors.black.withValues(alpha: 0.1),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: marquee.InfiniteMarquee(
        speed: speed,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Text(
            '$text   •   ',
            style: GoogleFonts.oswald(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: textColor ?? Colors.black.withValues(alpha: 0.1),
            ),
          );
        },
      ),
    );
  }
}
