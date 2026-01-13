import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/controller/verify_otp_controller.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final VerifyOtpController controller = Get.put(VerifyOtpController());

  // SMS Autofill
  static const platform = MethodChannel('sms_autofill');

  // Flag to prevent double submission
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    print('🔥🔥🔥 [OTP Screen] InitState called - Starting SMS listener setup');
    _listenForSms();
  }

  Future<void> _listenForSms() async {
    print('🔥 [SMS Listener] Starting SMS autofill setup...');
    try {
      // Request SMS permission and start listening
      print(
        '🔥 [SMS Listener] Calling platform.invokeMethod(startListening)...',
      );
      final result = await platform.invokeMethod('startListening');
      print('🔥 [SMS Listener] ✅ startListening result: $result');

      // Listen for SMS code
      print('🔥 [SMS Listener] Setting up method call handler...');
      platform.setMethodCallHandler((call) async {
        print('🔥🔥🔥 [SMS Listener] Method call received: ${call.method}');
        print('🔥 [SMS Listener] Arguments: ${call.arguments}');

        if (call.method == 'onSmsReceived') {
          final String? code = call.arguments as String?;
          print('🔥🔥🔥 [SMS Listener] OTP RECEIVED: $code');

          if (code != null && code.isNotEmpty) {
            print('🔥 [SMS Listener] Setting OTP in controller: $code');

            // Set flag to prevent onCompleted from also verifying
            _isVerifying = true;

            setState(() {
              controller.otpController.text = code;
            });
            print('🔥 [SMS Listener] OTP set successfully, UI updated');

            // Auto verify after receiving OTP
            await Future.delayed(const Duration(milliseconds: 800));
            if (mounted && code.length >= 4) {
              print('🔥 [SMS Listener] Auto-verifying OTP...');
              controller.verifyOtp();
            } else {
              print(
                '🔥 [SMS Listener] ❌ Cannot auto-verify: mounted=$mounted, code.length=${code.length}',
              );
            }
          } else {
            print('🔥 [SMS Listener] ❌ Code is null or empty');
          }
        } else {
          print('🔥 [SMS Listener] ⚠️ Unknown method: ${call.method}');
        }
        return null;
      });
      print('🔥 [SMS Listener] ✅ Method call handler set successfully');
    } catch (e) {
      print('🔥🔥🔥 [SMS Listener] ❌ ERROR setting up SMS autofill: $e');
      print('🔥 [SMS Listener] Error stack trace: ${StackTrace.current}');
    }
  }

  @override
  void dispose() {
    try {
      platform.invokeMethod('stopListening');
    } catch (e) {
      print('Error stopping SMS listener: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  colors: [Colors.black, Colors.grey.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [AppColors.appGreen, AppColors.appWhite],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizer().width5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: AppSizer().height6),
                  Center(
                    child: Image.asset(
                      "assets/images/OldMarketLogo.png",
                      height: AppSizer().height18,
                    ),
                  ),
                  SizedBox(height: AppSizer().height6),

                  // White Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            "Verify OTP",
                            style: TextStyle(
                              fontSize: AppSizer().fontSize22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: AppSizer().height1),

                          Obx(() {
                            String digitsOnly(String s) =>
                                s.replaceAll(RegExp(r'[^0-9]'), '');
                            final raw = controller.phone.value;
                            final d = digitsOnly(raw);
                            final display = d.length <= 10
                                ? d
                                : d.substring(d.length - 10);
                            return Text(
                              "OTP sent to: $display",
                              style: TextStyle(
                                fontSize: AppSizer().fontSize16,
                                color: AppColors.appGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }),
                          SizedBox(height: AppSizer().height4),

                          // PinCodeFields for better OTP input with autofill support
                          PinCodeTextField(
                            appContext: context,
                            length: 4,
                            controller: controller.otpController,
                            keyboardType: TextInputType.number,
                            animationType: AnimationType.fade,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(10),
                              fieldHeight: 50,
                              fieldWidth: 40,
                              activeFillColor: Colors.white,
                              inactiveFillColor: Colors.white,
                              selectedFillColor: Colors.white,
                              activeColor: AppColors.appGreen,
                              inactiveColor: Colors.grey,
                              selectedColor: AppColors.appPurple,
                            ),
                            animationDuration: const Duration(
                              milliseconds: 300,
                            ),
                            backgroundColor: Colors.transparent,
                            enableActiveFill: true,
                            cursorColor: AppColors.appGreen,
                            onCompleted: (code) {
                              print('[OTP] Code entered: $code');
                              // Only verify if not already verifying from SMS auto-fill
                              if (!_isVerifying) {
                                print('[OTP] Manual entry - Auto verifying...');
                                Future.delayed(
                                  const Duration(milliseconds: 300),
                                  () {
                                    controller.verifyOtp();
                                  },
                                );
                              } else {
                                print(
                                  '[OTP] Skipping verification - already handled by SMS listener',
                                );
                              }
                            },
                            onChanged: (value) {
                              print('[OTP] Current value: $value');
                              // Reset flag if user starts typing manually
                              if (_isVerifying && value.length < 4) {
                                setState(() {
                                  _isVerifying = false;
                                });
                              }
                            },
                            beforeTextPaste: (text) {
                              print('[OTP] Pasting text: $text');
                              return true; // Allow paste
                            },
                          ),
                          SizedBox(height: AppSizer().height4),
                          Obx(
                            () => InkWell(
                              onTap: controller.isLoading.value
                                  ? null
                                  : () {
                                      final otp = controller.otpController.text
                                          .trim();
                                      if (otp.length >= 4) {
                                        controller.verifyOtp();
                                      } else {
                                        Get.snackbar(
                                          "Error",
                                          "Please enter valid OTP",
                                          backgroundColor: AppColors.appRed,
                                          colorText: Colors.white,
                                        );
                                      }
                                    },
                              child: Container(
                                height: AppSizer().height6,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.appPurple,
                                      AppColors.appGreen,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: controller.isLoading.value
                                      ? const CircularProgressIndicator(
                                          color: AppColors.appWhite,
                                        )
                                      : Text(
                                          "Verify OTP",
                                          style: TextStyle(
                                            color: AppColors.appWhite,
                                            fontWeight: FontWeight.bold,
                                            fontSize: AppSizer().fontSize18,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: AppSizer().height2),
                          TextButton(
                            onPressed: () {
                              // Navigate to login so user can change phone number
                              Get.toNamed(AppRoutes.login);
                            },
                            child: Text(
                              "Change Phone Number?",
                              style: TextStyle(
                                color: AppColors.appPurple,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
