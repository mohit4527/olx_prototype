import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizer.dart';
import '../../controller/login_controller.dart';
import '../../utils/app_routes.dart';


class LogInScreen extends StatelessWidget {
  LogInScreen({super.key});

  // final _formKey = GlobalKey<FormState>();
  final loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(

                  gradient: LinearGradient(colors:
                  AppColors.appGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: AppSizer().height3,),
                         Container(
                           height: AppSizer().height15,
                           decoration: BoxDecoration(
                           ),
                           child: Image.asset("assets/images/OldMarketLogo.png",),
                         ),
                    SizedBox(height: AppSizer().height3,),
                    Container(
                      height: AppSizer().height82,
                      decoration: BoxDecoration(
                        color: AppColors.appWhite,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(70),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          // key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Hii Customers !",style: TextStyle(fontSize: AppSizer().fontSize22,fontWeight: FontWeight.w700),),
                                Text("Welcome to the Old Market.",style: TextStyle(color:AppColors.appGrey,fontSize: AppSizer().fontSize18,fontWeight: FontWeight.w700),),
                                Center(child: Icon(Icons.person,size:100,)),
                                SizedBox(height:AppSizer().height2),
                                Text("Email-Id",style:TextStyle(fontSize:AppSizer().fontSize17,fontWeight: FontWeight.bold),),
                                SizedBox(height:AppSizer().height1,),
                                // Obx( () =>
                                    TextField(
                                      // validator:(value){ return AppValidators.emailValidation(value!);},
                                      // controller: loginController.emailController,
                                      decoration: InputDecoration(
                                          hintText: "Enter your email-id",
                                          // errorText: loginController.isEmailValid.value ? null : "Enter a valid email",
                                          hintStyle:TextStyle(fontSize:AppSizer().fontSize17,fontWeight: FontWeight.w500),
                                          prefixIcon: Icon(Icons.mail),
                                          border:OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          )
                                      ),
                                      onChanged:(value){
                                        // loginController.validateEmail(value);
                                      },
                                    ),
                                // ),
                                SizedBox(height:AppSizer().height1),
                                Text("Password",style:TextStyle(fontSize:AppSizer().fontSize17,fontWeight: FontWeight.bold),),
                                SizedBox(height: AppSizer().height1,),
                                // Obx(
                                //       () =>
                                      TextField(
                                        // controller: loginController.passwordController,
                                        // obscureText: loginController.isPasswordHidden.value,
                                        decoration: InputDecoration(
                                          hintText: "Enter your password",
                                          // errorText: loginController.isPasswordValid.value ? null : "Enter a valid password" ,
                                          hintStyle:TextStyle(fontSize:AppSizer().fontSize17,fontWeight: FontWeight.w500),
                                          prefixIcon: Icon(Icons.lock),
                                          suffixIcon: IconButton( onPressed: (){
                                            // loginController.isPasswordHidden.toggle();
                                          },
                                            icon: Icon(
                                                loginController.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility),
                                          ),
                                          border:OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        onChanged: (value){
                                          loginController.validatePassword(value);
                                        },
                                      ),
                                // ),
                                SizedBox(height: AppSizer().height5,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Obx(
                                              ()  => Checkbox(value: loginController.rememberMe.value,
                                              onChanged: (val){
                                                loginController.rememberMe.value = val! ;
                                              }),
                                        ),
                                        Text("Remember me",style: TextStyle(fontSize: AppSizer().fontSize16,fontWeight: FontWeight.bold),)
                                      ],
                                    ),
                                    TextButton(onPressed: (){
                                      // Get.toNamed(AppRoutes.reset_password);
                                    }, child:
                                    Text("Forget Password?",style: TextStyle(fontSize: AppSizer().fontSize16,fontWeight: FontWeight.bold,color:AppColors.appPurple),))
                                  ],
                                ),
                                InkWell(
                                  onTap: (){
                                    Get.offAllNamed(AppRoutes.home);
                                    // loginController.login();
                                  },
                                  child: Container(
                                    height: AppSizer().height6,
                                    decoration: BoxDecoration(
                                     color: AppColors.appGreen,
                                      borderRadius: BorderRadius.only(
                                        bottomRight:Radius.circular(5),
                                        bottomLeft:Radius.circular(5),
                                        topLeft: Radius.circular(25),
                                      )
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Login",
                                        style: TextStyle(
                                          color: AppColors.appWhite,
                                          fontWeight: FontWeight.bold,
                                          fontSize: AppSizer().fontSize18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: AppSizer().height2,),
                                Center(
                                  child: RichText(text: TextSpan(text: "Don't have an account ?",
                                      style: TextStyle(color:AppColors.appBlack,fontSize:AppSizer().fontSize16,fontWeight: FontWeight.w500),
                                      children:[ TextSpan(text: " SignUp",
                                          style: TextStyle(color:AppColors.appPurple,fontWeight: FontWeight.bold,fontSize:AppSizer().fontSize17),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap=(){

                                            }
                                      ),
                                      ]
                                  )),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }
}