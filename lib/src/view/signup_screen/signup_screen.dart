import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import '../../controller/signup_controller.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  final SignupController _controller = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                colors: [Colors.black, Colors.grey.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : LinearGradient(
                colors: [AppColors.appGreen, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppSizer().width6),
                child: Column(
                  children: [
                    // Logo
                    Image.asset(
                      "assets/images/OldMarketLogo.png",
                      height: AppSizer().height16,
                    ),
                    SizedBox(height: AppSizer().height3),

                    // Glassmorphism Signup Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Center(
                              child: Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: AppSizer().fontSize22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            SizedBox(height: AppSizer().height3),

                            // Profile Image Section
                            Center(
                              child: Column(
                                children: [
                                  Obx(() => GestureDetector(
                                    onTap: () => _controller.pickProfileImage(),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.appGreen,
                                          width: 2,
                                        ),
                                        image: _controller.selectedProfileImage.value != null
                                            ? DecorationImage(
                                                image: FileImage(_controller.selectedProfileImage.value!),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: _controller.selectedProfileImage.value == null
                                          ? Icon(
                                              Icons.add_a_photo,
                                              size: 40,
                                              color: AppColors.appGrey,
                                            )
                                          : null,
                                    ),
                                  )),
                                  SizedBox(height: AppSizer().height1),
                                  Obx(() => _controller.selectedProfileImage.value != null
                                      ? TextButton(
                                          onPressed: () => _controller.removeProfileImage(),
                                          child: Text(
                                            "Remove Image",
                                            style: TextStyle(
                                              color: AppColors.appRed,
                                              fontSize: AppSizer().fontSize14,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          "Tap to add profile image (optional)",
                                          style: TextStyle(
                                            color: AppColors.appGrey,
                                            fontSize: AppSizer().fontSize14,
                                          ),
                                        )),
                                ],
                              ),
                            ),
                            SizedBox(height: AppSizer().height3),

                            // Full Name
                            Text("Full Name",
                                style: TextStyle(
                                  fontSize: AppSizer().fontSize16,
                                  fontWeight: FontWeight.bold,
                                )),
                            TextFormField(
                              controller: nameController,
                              validator: (value) =>
                              value!.isEmpty ? "Enter your name" : null,
                              decoration: InputDecoration(
                                hintText: "Enter full name",
                                prefixIcon: Icon(Icons.person),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            SizedBox(height: AppSizer().height2),

                            // Email
                            Text("Email Address",
                                style: TextStyle(
                                  fontSize: AppSizer().fontSize16,
                                  fontWeight: FontWeight.bold,
                                )),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => !GetUtils.isEmail(value!)
                                  ? "Enter valid email"
                                  : null,
                              decoration: InputDecoration(
                                hintText: "Enter email address",
                                prefixIcon: Icon(Icons.email),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            SizedBox(height: AppSizer().height2),

                            // Phone Number (no separate Send OTP button)
                            Text("Phone Number",
                                style: TextStyle(
                                  fontSize: AppSizer().fontSize16,
                                  fontWeight: FontWeight.bold,
                                )),
                            TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              validator: (value) => value!.length != 10
                                  ? "Enter valid 10-digit number"
                                  : null,
                              decoration: InputDecoration(
                                hintText: "Phone Number",
                                prefixIcon: Icon(Icons.phone_android),
                                prefixText: "+91 ",
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                counterText: "",
                              ),
                            ),
                            SizedBox(height: AppSizer().height2),

                            // OTP Field + Verify OTP
                            Obx(() => _controller.isOtpSent.value
                                ? Column(
                              children: [
                                TextFormField(
                                  controller: otpController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  decoration: InputDecoration(
                                    hintText: "Enter OTP",
                                    prefixIcon: Icon(Icons.lock),
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(20)),
                                    counterText: "",
                                  ),
                                ),
                                SizedBox(height: AppSizer().height2),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _controller.verifyOtp(otpController.text),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(20)),
                                      padding: EdgeInsets.symmetric(
                                          vertical: AppSizer().height2),
                                      backgroundColor: AppColors.appGreen,
                                    ),
                                    child: _controller.isVerifyingOtp.value
                                        ? CircularProgressIndicator(color: Colors.white)
                                        : Text("Verify OTP",style: TextStyle(color: AppColors.appWhite),),
                                  ),
                                ),
                                SizedBox(height: AppSizer().height2),
                              ],
                            )
                                : SizedBox()),

                            SizedBox(height: AppSizer().height3),

                            // Register Button
                            Obx(() => InkWell(
                              onTap: !_controller.isLoading.value && !_controller.isOtpSent.value
                                  ? () {
                                if (_formKey.currentState!.validate()) {
                                  _controller.registerUser(
                                    name: nameController.text.trim(),
                                    email: emailController.text.trim(),
                                    phone: phoneController.text.trim(),
                                  );
                                }
                              }
                                  : null,
                              child: Container(
                                height: AppSizer().height6,
                                decoration: BoxDecoration(
                                  gradient: !_controller.isOtpSent.value
                                      ? LinearGradient(
                                    colors: [
                                      AppColors.appPurple,
                                      AppColors.appGreen
                                    ],
                                  )
                                      : LinearGradient(
                                    colors: [
                                      AppColors.appGrey,
                                      AppColors.appGrey.shade400,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: _controller.isLoading.value
                                      ? CircularProgressIndicator(color: Colors.white)
                                      : Text(
                                    !_controller.isOtpSent.value
                                        ? "Register & Send OTP"
                                        : "OTP Sent - Enter Below",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppSizer().fontSize18,
                                    ),
                                  ),
                                ),
                              ),
                            )),

                            SizedBox(height: AppSizer().height3),

                            // Complete Registration Button (after OTP verification)
                            Obx(() => _controller.isOtpVerified.value
                                ? Column(
                              children: [
                                Container(
                                  height: AppSizer().height6,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.shade600,
                                        Colors.green.shade400,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          "Registration Complete!",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: AppSizer().fontSize18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: AppSizer().height2),
                              ],
                            )
                                : SizedBox()),

                            // Back to Login
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: "Already have an account? ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontStyle: FontStyle.italic,
                                    fontSize: AppSizer().fontSize17,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Login",
                                      style: TextStyle(
                                        color: AppColors.appPurple,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Get.back();
                                        },
                                    ),
                                  ],
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
        ],
      ),
    );
  }
}
