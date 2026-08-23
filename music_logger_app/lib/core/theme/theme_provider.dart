import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod provider for theme mode override.
/// 
/// When null, uses system theme mode.
/// When set to a specific ThemeMode, overrides system preference.
final themeModeProvider = StateProvider<ThemeMode?>((ref) => null);
