import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/controller/login_controller.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';

class LogInScreen extends StatelessWidget {
  LogInScreen({super.key});

  final loginController = Get.put(LoginController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          /// Background Gradient
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

          /// Main Body
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppSizer().width6),
                child: Column(
                  children: [
                    /// Logo
                    Image.asset(
                      "assets/images/OldMarketLogo.png",
                      height: AppSizer().height16,
                    ),

                    SizedBox(height: AppSizer().height3),

                    /// Glassmorphism Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Title
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    "Hii Customers 👋",
                                    style: TextStyle(
                                      fontSize: AppSizer().fontSize22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Welcome to the Old Market",
                                    style: TextStyle(
                                      color: AppColors.appGrey,
                                      fontSize: AppSizer().fontSize16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: AppSizer().height3),

                            /// Sub Text
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    "OTP Verification",
                                    style: TextStyle(
                                      fontSize: AppSizer().fontSize18,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  SizedBox(height: AppSizer().height1),
                                  Text(
                                    "We will send you an OTP on your number",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: AppSizer().fontSize15,
                                      color: AppColors.appPurple,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: AppSizer().height4),

                            /// Phone Input
                            Text(
                              "Phone Number",
                              style: TextStyle(
                                fontSize: AppSizer().fontSize16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: AppSizer().height1),
                            TextFormField(
                              maxLength: 10,
                              keyboardType: TextInputType.phone,
                              controller: loginController.phoneController,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length != 10 ||
                                    !GetUtils.isNumericOnly(value)) {
                                  return "Enter valid 10-digit number";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "Enter your phone number",
                                prefixIcon: const Icon(Icons.phone_iphone),
                                prefixText: "+91 ",
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),

                            SizedBox(height: AppSizer().height3),

                            /// Send OTP Button
                            Obx(
                              () => InkWell(
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    loginController.loginWithPhone();
                                  }
                                },
                                child: Container(
                                  height: AppSizer().height6,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.appPurple,
                                        AppColors.appGreen,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: loginController.isLoading.value
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : Text(
                                            "Send OTP",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: AppSizer().fontSize18,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: AppSizer().height1),

                            /// Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: AppColors.appGrey,
                                    thickness: 1.2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    "or continue with",
                                    style: TextStyle(
                                      color: AppColors.appPurple,
                                      fontSize: AppSizer().fontSize15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: AppColors.appGrey,
                                    thickness: 1.2,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: AppSizer().height3),

                            /// Social Buttons
                            Center(
                              child: _socialButton(
                                "assets/images/google (1).png",
                                onTap: () {
                                  loginController.signInWithGoogle();
                                },
                              ),
                            ),

                            SizedBox(height: AppSizer().height3),

                            /// Signup Text
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: "Don’t have an account? ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: AppSizer().fontSize16,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Sign Up",
                                      style: TextStyle(
                                        color: AppColors.appPurple,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Get.toNamed(AppRoutes.signup_screen);
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

  /// Custom Social Button
  Widget _socialButton(String assetPath, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: Image.asset(assetPath, height: 28)),
      ),
    );
  }
}
