import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/controller/login_controller.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/custom_widgets/button_with_icons.dart';

class LogInScreen extends StatelessWidget {
  LogInScreen({super.key});

  final loginController = Get.put(LoginController());
  final _formKey = GlobalKey<FormState>();

  late AnimationController shakeController;
  late Animation<Offset> shakeAnimation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: AppSizer().height100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.appGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizer().width5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: AppSizer().height5),

                  Center(
                    child: AnimatedBuilder(
                      animation: loginController.shakeController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            loginController.shakeAnimation.value,
                            0,
                          ),
                          child: child,
                        );
                      },
                      child: Image.asset(
                        "assets/images/OldMarketLogo.png",
                        height: AppSizer().height16,
                      ),
                    ),
                  ),

                  SizedBox(height: AppSizer().height5),
                  /// Login Form Box
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              "Hii Customers !",
                              style: TextStyle(
                                fontSize: AppSizer().fontSize22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              "Welcome to the Old Market.",
                              style: TextStyle(
                                color: AppColors.appGrey,
                                fontSize: AppSizer().fontSize18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(height: AppSizer().height3),
                          Center(
                            child: Text(
                              "OTP Verification",
                              style: TextStyle(
                                fontSize: AppSizer().fontSize18,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          SizedBox(height: AppSizer().height1),
                          Center(
                            child: Text(
                              "We will send you an OTP on this mobile number",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizer().fontSize16,
                                color: AppColors.appPurple,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: AppSizer().height4),

                          /// Phone Input
                          Text(
                            "Phone Number -",
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
                                return "Enter valid 10-digit mobile number";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Enter your phone no.",
                              prefixIcon: const Icon(Icons.phone_android),
                              prefixText: "+91 ",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          SizedBox(height: AppSizer().height4),

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
                                  color: AppColors.appGreen,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: loginController.isLoading.value
                                      ? const CircularProgressIndicator(
                                          color: AppColors.appWhite,
                                        )
                                      : Text(
                                          "Send OTP",
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
                          SizedBox(height: AppSizer().height3),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color:AppColors.appGrey,
                                  height: 1,
                                  thickness: 1.2,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  "or continue with",
                                  style: TextStyle(
                                    color: AppColors.appPurple,
                                    fontSize: AppSizer().fontSize16,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppColors.appGrey,
                                  height: 1,
                                  thickness: 1.2,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSizer().height3),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SocialButton(
                                  onTap: (){
                                    print("Google Button Tapped");
                                  },
                                name: "Google",
                                  iconpath:"assets/images/google (1).png",),
                              SocialButton(
                                  onTap: (){
                                    print("Facebook Button Tapped");
                                  },
                                  iconpath: "assets/images/fb.png",
                                  name:"Facebook",
                              )
                                ],
                              )
                        ],
                      ),
                    ),
                  ),
                  // SizedBox(height: AppSizer().height4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
