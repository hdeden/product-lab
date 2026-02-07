import 'package:flutter/material.dart';

const hrisBlue = Color(0xFF2563EB);
const hrisBlueDark = Color(0xFF1E40AF);
const hrisGray50 = Color(0xFFF9FAFB);
const hrisGray200 = Color(0xFFE5E7EB);
const hrisGray500 = Color(0xFF6B7280);

LinearGradient hrisHeaderGradient() {
  return const LinearGradient(
    colors: [hrisBlue, hrisBlueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
