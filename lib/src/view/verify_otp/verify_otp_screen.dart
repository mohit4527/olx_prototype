import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/controller/verify_otp_controller.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final VerifyOtpController controller = Get.put(VerifyOtpController());

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

                          TextFormField(
                            controller: controller.otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            validator: (value) {
                              if (value == null ||
                                  (value.length != 4 && value.length != 6)) {
                                return "Enter 4 or 6-digit OTP";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Enter OTP",
                              prefixIcon: const Icon(Icons.lock),
                              counterText: "",
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          SizedBox(height: AppSizer().height4),
                          Obx(
                            () => InkWell(
                              onTap: controller.isLoading.value
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        controller.verifyOtp();
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
                          // Debug: show last request/response saved (dev only)
                          TextButton(
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final req =
                                  prefs.getString('last_verify_request') ??
                                  'No request saved';
                              final res =
                                  prefs.getString('last_verify_response') ??
                                  'No response saved';
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text(
                                    'Last verify request/response',
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Request:'),
                                        SelectableText(req),
                                        const SizedBox(height: 12),
                                        const Text('Response:'),
                                        SelectableText(res),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        final combined =
                                            'Request:\n' +
                                            req +
                                            '\n\nResponse:\n' +
                                            res;
                                        await Clipboard.setData(
                                          ClipboardData(text: combined),
                                        );
                                        Get.back();
                                        Get.snackbar(
                                          'Copied',
                                          'Request and response copied to clipboard',
                                        );
                                      },
                                      child: const Text('Copy'),
                                    ),
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text(
                              "Show last API exchange (debug)",
                              style: TextStyle(
                                color: AppColors.appPurple,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
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
