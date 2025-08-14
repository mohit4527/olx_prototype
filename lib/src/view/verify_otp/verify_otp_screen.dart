import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/controller/verify_otp_controller.dart';

class VerifyOtpScreen extends StatelessWidget {
  VerifyOtpScreen({super.key});

  final VerifyOtpController controller = Get.put(VerifyOtpController(), permanent: false);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: AppSizer().height100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.appGradient,
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

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
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
                          Text(
                            "OTP sent to: ${controller.phone}",
                            style: TextStyle(
                              fontSize: AppSizer().fontSize16,
                              color: AppColors.appPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: AppSizer().height4),

                          TextFormField(
                            controller: controller.otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            validator: (value) {
                              if (value == null || value.length != 4) {
                                return "Enter 4-digit OTP";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Enter OTP",
                              prefixIcon: const Icon(Icons.lock),
                              counterText: "",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          SizedBox(height: AppSizer().height4),

                          Obx(() => InkWell(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                controller.verifyOtp();
                              }
                            },
                            child: Container(
                              height: AppSizer().height6,
                              decoration: BoxDecoration(
                                color: AppColors.appGreen,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: controller.isLoading.value
                                    ? const CircularProgressIndicator(color: AppColors.appWhite)
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
                          )),
                          SizedBox(height: AppSizer().height2),

                          TextButton(
                            onPressed: () {
                              Get.back(); // Back to login
                            },
                            child: const Text("Change Phone Number?"),
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
