import 'package:flutter/material.dart';

/// Widget đĩa than xoay tròn (vinyl disc)
/// Tách từ song_detail_screen.dart
class VinylDisc extends StatelessWidget {
  final AnimationController animationController;
  final String coverUrl;

  const VinylDisc({
    Key? key,
    required this.animationController,
    required this.coverUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
        turns: animationController,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipOval(
                child: Image.network(
                  coverUrl,
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black87, width: 15),
                ),
              ),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF121212),
                  border: Border.all(color: Colors.white38, width: 2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
