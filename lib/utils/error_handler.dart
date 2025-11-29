import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ErrorHandler {
  /// Convert Firebase Auth exceptions to user-friendly messages
  static String getAuthErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email is already registered. Please login instead.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'operation-not-allowed':
          return 'This operation is not allowed. Please contact support.';
        case 'weak-password':
          return 'Password is too weak. Please use a stronger password.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support.';
        case 'user-not-found':
          return 'No account found with this email. Please sign up first.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-credential':
          return 'Invalid email or password. Please try again.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'requires-recent-login':
          return 'Please log in again to complete this action.';
        default:
          debugPrint('Unhandled Firebase Auth error: ${error.code}');
          return error.message ?? 'An error occurred. Please try again.';
      }
    }

    return 'An unexpected error occurred. Please try again.';
  }

  /// Convert Firestore exceptions to user-friendly messages
  static String getFirestoreErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('permission-denied') ||
        errorString.contains('permission denied')) {
      return 'You do not have permission to perform this action.';
    }

    if (errorString.contains('not-found') ||
        errorString.contains('not found')) {
      return 'The requested data was not found.';
    }

    if (errorString.contains('already-exists') ||
        errorString.contains('already exists')) {
      return 'This data already exists.';
    }

    if (errorString.contains('unavailable')) {
      return 'Service temporarily unavailable. Please try again.';
    }

    if (errorString.contains('deadline-exceeded') ||
        errorString.contains('timeout')) {
      return 'Request timed out. Please check your connection and try again.';
    }

    debugPrint('Unhandled Firestore error: $error');
    return 'An error occurred while saving data. Please try again.';
  }

  /// Generic error handler with logging
  static String handleError(dynamic error, {String? context}) {
    // Log error for debugging
    debugPrint('Error${context != null ? ' in $context' : ''}: $error');

    // Return user-friendly message based on error type
    if (error is FirebaseAuthException) {
      return getAuthErrorMessage(error);
    }

    if (error.toString().contains('firestore') ||
        error.toString().contains('cloud_firestore')) {
      return getFirestoreErrorMessage(error);
    }

    // Network errors
    if (error.toString().toLowerCase().contains('network') ||
        error.toString().toLowerCase().contains('socket')) {
      return 'Network error. Please check your internet connection.';
    }

    // Generic fallback
    return 'An unexpected error occurred. Please try again.';
  }

  /// Log error for debugging (can be extended to use crash reporting services)
  static void logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
  }) {
    debugPrint('=== ERROR LOG ===');
    if (context != null) {
      debugPrint('Context: $context');
    }
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
    debugPrint('=================');

    // TODO: In production, send to crash reporting service (e.g., Firebase Crashlytics)
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: context);
  }
}
