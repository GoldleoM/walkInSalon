import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:walkinsalonapp/utils/error_handler.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:walkinsalonapp/models/customer_model.dart';

class CustomerAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final gsi.GoogleSignIn _googleSignIn = gsi.GoogleSignIn();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  /// Sign up new customer
  Future<Map<String, dynamic>> signUpCustomer({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      // Create Firebase Auth user
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      final uid = credential.user!.uid;

      // Create user document in Firestore
      await _firestore.collection('users').doc(uid).set({
        'email': email.trim().toLowerCase(),
        'name': name.trim(),
        'phoneNumber': phoneNumber?.trim(),
        'role': 'customer',
        'emailVerified': false,
        'profileImage': null,
        'favoriteSalons': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send email verification
      await credential.user!.sendEmailVerification();

      debugPrint('Customer signed up successfully: $uid');

      return {
        'success': true,
        'uid': uid,
        'message': 'Account created successfully! Please verify your email.',
      };
    } on FirebaseAuthException catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'signUpCustomer');
      return {'success': false, 'message': ErrorHandler.getAuthErrorMessage(e)};
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'signUpCustomer');
      return {
        'success': false,
        'message': ErrorHandler.handleError(e, context: 'signUpCustomer'),
      };
    }
  }

  /// Login existing customer
  Future<Map<String, dynamic>> loginCustomer({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Auth
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;

      // Verify user is a customer
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        await _auth.signOut();
        return {
          'success': false,
          'message': 'User account not found. Please sign up first.',
        };
      }

      final role = userDoc.data()?['role'];
      if (role != 'customer') {
        await _auth.signOut();
        return {
          'success': false,
          'message':
              'This account is not a customer account. Please use the business login.',
        };
      }

      debugPrint('Customer logged in successfully: $uid');

      return {
        'success': true,
        'uid': uid,
        'message': 'Login successful!',
        'profileComplete':
            userDoc.data()?['name'] != null &&
            (userDoc.data()?['name'] as String).isNotEmpty,
      };
    } on FirebaseAuthException catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'loginCustomer');
      return {'success': false, 'message': ErrorHandler.getAuthErrorMessage(e)};
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'loginCustomer');
      return {
        'success': false,
        'message': ErrorHandler.handleError(e, context: 'loginCustomer'),
      };
    }
  }

  /// Sign in with Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      User? user;

      if (kIsWeb) {
        debugPrint('WEB: Starting signInWithPopup...');
        // Web: Use signInWithPopup
        final UserCredential userCredential = await _auth.signInWithPopup(
          GoogleAuthProvider(),
        );
        debugPrint(
          'WEB: signInWithPopup completed. User: ${userCredential.user?.uid}',
        );
        user = userCredential.user;
      } else {
        // Mobile: Use native flow
        final gsi.GoogleSignInAccount? googleUser = await _googleSignIn
            .signIn();

        if (googleUser == null) {
          return {'success': false, 'message': 'Sign in cancelled by user'};
        }

        final gsi.GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );
        user = userCredential.user;
      }

      if (user == null) {
        return {'success': false, 'message': 'Authentication failed'};
      }

      final uid = user.uid;

      // Check if user exists in Firestore
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        // Create new customer account
        await _firestore.collection('users').doc(uid).set({
          'email': user.email!.toLowerCase(),
          'name': user.displayName ?? 'New User',
          'phoneNumber': user.phoneNumber,
          'role': 'customer', // Default to customer
          'emailVerified': true, // Google accounts are verified
          'profileImage': user.photoURL,
          'favoriteSalons': [],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      // Note: Existing logic for checking role is omitted here as we want to allow login
      // regardless of role here (or at least not block it inside the service for now).
      // The AuthWrapper handles the navigation based on actual role.

      debugPrint('Google Sign-In successful: $uid');
      return {
        'success': true,
        'uid': uid,
        'message': 'Google Sign-In successful!',
      };
    } on FirebaseAuthException catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'signInWithGoogle');
      return {'success': false, 'message': ErrorHandler.getAuthErrorMessage(e)};
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'signInWithGoogle');
      return {
        'success': false,
        'message': ErrorHandler.handleError(e, context: 'signInWithGoogle'),
      };
    }
  }

  /// Send password reset email
  Future<Map<String, dynamic>> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());

      debugPrint('Password reset email sent to: $email');

      return {
        'success': true,
        'message': 'Password reset email sent! Please check your inbox.',
      };
    } on FirebaseAuthException catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'resetPassword');
      return {'success': false, 'message': ErrorHandler.getAuthErrorMessage(e)};
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'resetPassword');
      return {
        'success': false,
        'message': ErrorHandler.handleError(e, context: 'resetPassword'),
      };
    }
  }

  /// Update customer profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phoneNumber,
    String? profileImage,
  }) async {
    try {
      final uid = currentUserId;
      if (uid == null) {
        return {'success': false, 'message': 'No user logged in'};
      }

      final Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name.trim();
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber.trim();
      if (profileImage != null) updates['profileImage'] = profileImage;

      await _firestore.collection('users').doc(uid).update(updates);

      debugPrint('Customer profile updated: $uid');

      return {'success': true, 'message': 'Profile updated successfully!'};
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'updateProfile');
      return {
        'success': false,
        'message': ErrorHandler.handleError(e, context: 'updateProfile'),
      };
    }
  }

  /// Get customer profile
  Future<CustomerModel?> getCustomerProfile() async {
    try {
      final uid = currentUserId;
      if (uid == null) return null;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      return CustomerModel.fromMap(doc.data()!, uid);
    } catch (e) {
      ErrorHandler.logError(
        e,
        StackTrace.current,
        context: 'getCustomerProfile',
      );
      return null;
    }
  }

  /// Add salon to favorites
  Future<Map<String, dynamic>> addFavoriteSalon(String salonId) async {
    try {
      final uid = currentUserId;
      if (uid == null) {
        return {'success': false, 'message': 'No user logged in'};
      }

      await _firestore.collection('users').doc(uid).update({
        'favoriteSalons': FieldValue.arrayUnion([salonId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'message': 'Added to favorites!'};
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'addFavoriteSalon');
      return {
        'success': false,
        'message': ErrorHandler.handleError(e, context: 'addFavoriteSalon'),
      };
    }
  }

  /// Remove salon from favorites
  Future<Map<String, dynamic>> removeFavoriteSalon(String salonId) async {
    try {
      final uid = currentUserId;
      if (uid == null) {
        return {'success': false, 'message': 'No user logged in'};
      }

      await _firestore.collection('users').doc(uid).update({
        'favoriteSalons': FieldValue.arrayRemove([salonId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {'success': true, 'message': 'Removed from favorites!'};
    } catch (e) {
      ErrorHandler.logError(
        e,
        StackTrace.current,
        context: 'removeFavoriteSalon',
      );
      return {
        'success': false,
        'message': ErrorHandler.handleError(e, context: 'removeFavoriteSalon'),
      };
    }
  }

  /// Resend email verification
  Future<Map<String, dynamic>> resendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) {
        return {'success': false, 'message': 'No user logged in'};
      }

      if (user.emailVerified) {
        return {'success': false, 'message': 'Email is already verified'};
      }

      await user.sendEmailVerification();

      return {
        'success': true,
        'message': 'Verification email sent! Please check your inbox.',
      };
    } on FirebaseAuthException catch (e) {
      ErrorHandler.logError(
        e,
        StackTrace.current,
        context: 'resendEmailVerification',
      );
      return {'success': false, 'message': ErrorHandler.getAuthErrorMessage(e)};
    } catch (e) {
      ErrorHandler.logError(
        e,
        StackTrace.current,
        context: 'resendEmailVerification',
      );
      return {
        'success': false,
        'message': ErrorHandler.handleError(
          e,
          context: 'resendEmailVerification',
        ),
      };
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      debugPrint('Customer signed out');
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'signOut');
      rethrow;
    }
  }

  /// Delete account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final uid = currentUserId;
      if (uid == null) {
        return {'success': false, 'message': 'No user logged in'};
      }

      // Delete Firestore data
      await _firestore.collection('users').doc(uid).delete();

      // Delete Firebase Auth account
      await currentUser!.delete();

      debugPrint('Customer account deleted: $uid');

      return {'success': true, 'message': 'Account deleted successfully'};
    } on FirebaseAuthException catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'deleteAccount');
      return {'success': false, 'message': ErrorHandler.getAuthErrorMessage(e)};
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current, context: 'deleteAccount');
      return {
        'success': false,
        'message': ErrorHandler.handleError(e, context: 'deleteAccount'),
      };
    }
  }
}
