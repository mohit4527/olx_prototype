import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/controller/token_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:olx_prototype/src/controller/get_profile_controller.dart';
import 'package:olx_prototype/src/services/apiServices/apiServices.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:olx_prototype/src/controller/dealer_controller.dart'; // 🔥 Added dealer controller import

/// LoginController for handling login logic
class LoginController extends GetxController {
  // Observables
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var currentUser = Rxn<User>();

  // Firebase Auth (keeping for Google sign-in)
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // Phone auth
  final TextEditingController phoneController = TextEditingController();
  String? verificationId;
  String? currentPhone; // Store current phone for OTP verification

  // Token controller
  final TokenController tokenController = Get.find<TokenController>();

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _auth.currentUser;
    isLoggedIn.value = _auth.currentUser != null;

    _auth.authStateChanges().listen((user) {
      currentUser.value = user;
      isLoggedIn.value = user != null;
    });
  }

  /// NEW: Login with phone number using API
  Future<void> loginWithPhone() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      Get.snackbar("Error", "Phone number cannot be empty");
      return;
    }

    try {
      isLoading.value = true;

      final result = await ApiService.login(phone, "+91");

      if (result['success'] == true) {
        currentPhone = phone; // Store phone for OTP verification
        // Mark active phone so profile loads the right data
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('active_user_phone', phone);
          if (Get.isRegistered<GetProfileController>()) {
            Get.find<GetProfileController>().loadProfileFromPrefs();
          }
        } catch (_) {}
        // On success, assume server sent OTP and navigate to Verify OTP screen.
        // Some backend responses may not include a nested `user` object but still
        // send the OTP. Navigating here improves UX; Verify flow will handle
        // actual verification and registration status.
        Get.snackbar(
          "Success",
          result['message'] ?? "OTP sent successfully",
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          snackPosition: SnackPosition.TOP,
        );

        // Store the current phone for downstream flows and navigate to OTP screen
        currentPhone = phone;
        Get.toNamed(
          AppRoutes.verify_otp,
          arguments: {"phone": phone, "countryCode": "+91"},
        );
      } else {
        Get.snackbar(
          "Login Failed",
          result['message'] ?? "Failed to send OTP",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Phone authentication
  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      isLoading.value = true;
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          isLoading.value = false;
          // Ensure profile controller reads active phone pref
          try {
            final prefs = await SharedPreferences.getInstance();
            if (currentPhone != null) {
              await prefs.setString('active_user_phone', currentPhone!);
            }
            if (Get.isRegistered<GetProfileController>()) {
              Get.find<GetProfileController>().loadProfileFromPrefs();
            }

            // 🔥 IMPROVED: Check dealer profile for current user after login
            if (Get.isRegistered<DealerProfileController>()) {
              final dealerController = Get.find<DealerProfileController>();
              print(
                '🔍 [LoginController] Checking dealer profile for logged in user...',
              );
              await dealerController.checkIfProfileExists();

              // Force refresh state after check
              dealerController.isProfileCreated.refresh();
              print(
                '✅ [LoginController] Dealer profile check completed - isProfileCreated: ${dealerController.isProfileCreated.value}',
              );
            } else {
              print(
                '⚠️ [LoginController] DealerProfileController not registered',
              );
            }
          } catch (loginError) {
            print('💥 [LoginController] Error in login process: $loginError');
          }
          Get.offAllNamed(AppRoutes.home);
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          String errorMessage = "";
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage =
                  "Please check your phone number format and try again. Include country code (+91)";
              break;
            case 'too-many-requests':
              errorMessage =
                  "Too many attempts. Please wait a while before trying again";
              break;
            case 'network-request-failed':
              errorMessage = "Network error. Check your internet connection";
              break;
            case 'quota-exceeded':
              errorMessage =
                  "Service temporarily unavailable. Try again in a few minutes";
              break;
            default:
              errorMessage = "Error: ${e.message}\nCode: ${e.code}";
          }
          Get.snackbar(
            "Verification Failed",
            errorMessage,
            duration: const Duration(seconds: 8),
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade900,
            snackPosition: SnackPosition.TOP,
          );
          print(
            "Firebase Auth Error - Code: ${e.code}, Message: ${e.message}",
          ); // For debugging
        },

        codeSent: (String verId, int? resendToken) {
          verificationId = verId;
          isLoading.value = false;
          Get.toNamed(
            AppRoutes.verify_otp,
            arguments: {"verificationId": verId, "phone": phoneNumber},
          );
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Phone Login Error", e.toString());
    }
  }

  /// Verify OTP
  Future<void> verifyOtp(String otp) async {
    if (verificationId == null) {
      Get.snackbar("Error", "Verification ID is null");
      return;
    }
    try {
      isLoading.value = true;
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);

      // 🔥 IMPROVED: Check dealer profile for current user after OTP login
      try {
        if (Get.isRegistered<DealerProfileController>()) {
          final dealerController = Get.find<DealerProfileController>();
          print('🔍 [LoginController] OTP Login - Checking dealer profile...');
          await dealerController.checkIfProfileExists();
          dealerController.isProfileCreated.refresh();
          print(
            '✅ [LoginController] OTP Login - Profile check completed: ${dealerController.isProfileCreated.value}',
          );
        }
      } catch (otpError) {
        print('💥 [LoginController] OTP Login error: $otpError');
      }

      isLoading.value = false;
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("OTP Error", e.toString());
    }
  }

  /// Google Sign-In with improved error handling
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        isLoading.value = false;
        Get.snackbar(
          "Cancelled",
          "Google sign-in was cancelled",
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade900,
          snackPosition: SnackPosition.TOP,
        );
        return; // User cancelled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // Store user info in TokenController if needed
        await tokenController.saveUserInfo({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'loginMethod': 'google',
        });
        // Mark as logged in (external provider)
        try {
          await tokenController.markLoggedInViaExternal();
        } catch (e) {
          print('⚠️ Could not mark external login: $e');
        }

        Get.snackbar(
          "Welcome!",
          "Signed in as ${user.displayName ?? user.email}",
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          snackPosition: SnackPosition.TOP,
        );

        // 🔥 IMPROVED: Check dealer profile for current user after Google login
        try {
          if (Get.isRegistered<DealerProfileController>()) {
            final dealerController = Get.find<DealerProfileController>();
            print(
              '🔍 [LoginController] Google Login - Checking dealer profile...',
            );
            await dealerController.checkIfProfileExists();
            dealerController.isProfileCreated.refresh();
            print(
              '✅ [LoginController] Google Login - Profile check completed: ${dealerController.isProfileCreated.value}',
            );
          }
        } catch (googleError) {
          print('💥 [LoginController] Google Login error: $googleError');
        }

        // Navigate to home
        Get.offAllNamed(AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Google sign-in failed";
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage =
              "An account already exists with this email but different sign-in method";
          break;
        case 'invalid-credential':
          errorMessage = "Invalid credentials. Please try again";
          break;
        case 'operation-not-allowed':
          errorMessage =
              "Google sign-in is not enabled. Please contact support";
          break;
        case 'user-disabled':
          errorMessage = "This account has been disabled";
          break;
        case 'user-not-found':
          errorMessage = "No account found with this email";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password";
          break;
        case 'network-request-failed':
          errorMessage = "Network error. Check your internet connection";
          break;
        default:
          errorMessage = "Error: ${e.message}";
      }

      Get.snackbar(
        "Google Sign-In Failed",
        errorMessage,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );

      print("Firebase Auth Error - Code: ${e.code}, Message: ${e.message}");
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong: ${e.toString()}",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
      print("General Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout with proper cleanup
  Future<void> signOut() async {
    try {
      // Sign out from Firebase
      await _auth.signOut();

      // Sign out from Google
      await _googleSignIn.signOut();

      // Clear tokens and user data
      await tokenController.clearToken();

      // 🔥 NEW: Clear dealer profile data for current user
      try {
        if (Get.isRegistered<DealerProfileController>()) {
          final dealerController = Get.find<DealerProfileController>();
          dealerController.isProfileCreated.value = false;
          await dealerController.clearDealerDataFromPrefs();
        }
      } catch (_) {}

      // Update observables
      isLoggedIn.value = false;
      currentUser.value = null;

      Get.snackbar(
        "Signed Out",
        "You have been successfully signed out",
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade900,
        snackPosition: SnackPosition.TOP,
      );

      // Navigate to login
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        "Sign Out Error",
        "Failed to sign out: ${e.toString()}",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Navigation helper
  void checkLoginAndNavigate(String routeName, {Object? arguments}) {
    if (isLoggedIn.value) {
      Get.toNamed(routeName, arguments: arguments);
    } else {
      Get.toNamed(AppRoutes.login);
    }
  }
}
