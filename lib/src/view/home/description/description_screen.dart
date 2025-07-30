import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/controller/description_controller.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../../../controller/book_test_drive_controller.dart';
import '../../../custom_widgets/longpress_image_section.dart';

class DescriptionScreen extends StatelessWidget {
  DescriptionScreen({super.key});
  final controller = Get.put(DescriptionController());
  final bookTestDriveController = Get.put(BookTestDriveController());
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    controller.fetchProducts();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        title: Text("Product Desription...",style: TextStyle(color: AppColors.appWhite),),
        centerTitle: true,
        leading: IconButton(onPressed: (){
          Get.offAllNamed(AppRoutes.home);
        },
            icon: Icon(Icons.arrow_back,color:AppColors.appWhite,)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSizer().height1,),
          Obx(() {
            if (controller.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }

            if (controller.product.isEmpty) {
              return Center(child: Text("No products found"));
            }

            final product = controller.product[0];

            return SizedBox(
              height: AppSizer().height24,
              child: PageView.builder(
                controller: _pageController,
                itemCount: product.mediaUrl.length,
                itemBuilder: (context, imageIndex) {
                  final imagePath = product.mediaUrl[imageIndex].replaceAll('\\', '/');

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      'https://oldmarket.bhoomi.cloud/$imagePath',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/images/placeholder.jpg', fit: BoxFit.cover);
                      },
                    ),
                  );
                },
              ),
            );

          }),


          SizedBox(height:AppSizer().height2),
              Center(
                child: Obx(() {
                  if (controller.isLoading.value || controller.product.isEmpty) {
                    return SizedBox(); // or CircularProgressIndicator if needed
                  }

                  final product = controller.product[0]; // Assuming 1 product

                  return SmoothPageIndicator(
                    controller: _pageController,
                    count: product.mediaUrl.length,
                    effect: SlideEffect(
                      dotHeight: 4,
                      dotWidth: AppSizer().width5,
                      radius: 2,
                      spacing: AppSizer().height1,
                      dotColor: Colors.grey,
                      activeDotColor: AppColors.appGreen,
                    ),
                  );
                }),

              ),
              SizedBox(height: AppSizer().height3,),
              Obx(() {
                if (controller.product.isEmpty) return SizedBox();

                final product = controller.product[0];

                return Text(
                  "User Id: ${product.id ?? 'N/A'}",
                  style: TextStyle(
                    fontSize: AppSizer().fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }),

              SizedBox(height: AppSizer().height1,),
              Obx(() {
                if (controller.product.isEmpty) return SizedBox();

                final product = controller.product[0];

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹ ${product.price}",
                      style: TextStyle(
                        fontSize: AppSizer().fontSize19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: AppSizer().width4),
                        Icon(Icons.favorite_border),
                      ],
                    )
                  ],
                );
              }),

              SizedBox(height: AppSizer().height1,),

              Obx(() {
                if (controller.product.isEmpty) return SizedBox();

                final product = controller.product[0];

                return Text(
                  product.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: AppSizer().fontSize17,
                  ),
                );
              }),

              SizedBox(height: AppSizer().height1,),

              Obx(() {
                if (controller.product.isEmpty) return SizedBox();

                final product = controller.product[0];
                final createdAt = product.createdAt != null ? DateTime.tryParse(product.createdAt!) : null;

                String timeAgo = '';
                if (createdAt != null) {
                  timeAgo = timeago.format(createdAt, locale: 'en');
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${product.city ?? ""}, ${product.state ?? ""}, ${product.country ?? ""}',
                      style: TextStyle(
                        color: AppColors.appGrey,
                        fontSize: AppSizer().fontSize16,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.alarm,color: AppColors.appGrey,size: 20,),
                        SizedBox(width: 4),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            color: AppColors.appGrey,
                            fontSize: AppSizer().fontSize16,
                          ),
                        ),
                      ],
                    )
                  ],
                );
              }),


              SizedBox(height: AppSizer().height2,),
              Text("Description..",style: TextStyle(fontSize: AppSizer().fontSize19,
                  fontWeight: FontWeight.w700)),
              Divider(color: AppColors.appGreen,thickness: 1.5,),
              SizedBox(height: AppSizer().height2,),
              Obx( (){
                if (controller.product.isEmpty) return SizedBox();

                final product  = controller.product[0];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.description,style: TextStyle(fontSize: AppSizer().fontSize17,fontStyle: FontStyle.italic),),
                  ],
                );
              }),
              SizedBox(height: AppSizer().height2,),
              Text("Contact me - ", style: TextStyle(fontSize: AppSizer().fontSize17,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),),
              SizedBox(height: AppSizer().height3,),
              Row(
                children: [
                  InkWell(
                    onTap: () async {
                      final product = controller.product[0];
                      final phoneNumber = product.whatsapp ?? "";

                      if (await canLaunchUrl(Uri.parse("tel:$phoneNumber"))) {
                        await launchUrl(Uri.parse("tel:$phoneNumber"));
                      } else {
                        Get.snackbar("Error", "Unable to make a call");
                      }
                    },
                    child: Container(
                      height: AppSizer().height5,
                      width: AppSizer().width44,
                      decoration: BoxDecoration(
                        color: AppColors.appGreen,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Call", style: TextStyle(color: AppColors.appWhite)),
                          SizedBox(width: AppSizer().width3),
                          Icon(Icons.phone, color: AppColors.appWhite),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: AppSizer().width3),

                  InkWell(
                    onTap: () async {
                      final product = controller.product[0];
                      final whatsappNumber = product.whatsapp ?? "";
                      final message = Uri.encodeComponent("Hi, I'm interested in your product: ${product.title}");

                      final whatsappUrl = "https://wa.me/$whatsappNumber?text=$message";

                      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                        await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
                      } else {
                        Get.snackbar("Error", "WhatsApp not installed");
                      }
                    },
                    child: Container(
                      height: AppSizer().height5,
                      width: AppSizer().width44,
                      decoration: BoxDecoration(
                        color: AppColors.appGreen,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Go To Whatsapp", style: TextStyle(color: AppColors.appWhite)),
                          SizedBox(width: AppSizer().width3),
                          Icon(FontAwesomeIcons.whatsapp, color: AppColors.appWhite, size: 25),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizer().height5,),
              InkWell(
                onTap: () {
                  final product = controller.product[0]; // Assuming product[0] is always safe
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    isScrollControlled: true,
                    builder: (_) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                          left: 16,
                          right: 16,
                          top: 24,
                        ),
                        child: GetBuilder<BookTestDriveController>(
                          builder: (bookController) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Book Test Drive", style: TextStyle(fontSize: AppSizer().fontSize18, fontWeight: FontWeight.bold)),
                                SizedBox(height: AppSizer().height2),

                                TextFormField(
                                  controller: bookController.nameController,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.person),
                                    labelText: "Your Name",
                                    border: OutlineInputBorder(
                                      borderRadius:BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: bookController.phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.phone_android),
                                    labelText: "Phone Number",
                                    border: OutlineInputBorder(
                                      borderRadius:BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),

                                // Date Picker
                                InkWell(
                                  onTap: () => bookController.pickDate(context),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_month),
                                        SizedBox(width: AppSizer().width2,),
                                        Text(
                                          bookController.selectedDate != null
                                              ? bookController.formattedDate
                                              : "Select Date",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                // Time Picker
                                InkWell(
                                  onTap: () => bookController.pickTime(context),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.alarm),
                                        SizedBox(width: AppSizer().width2,),
                                        Text(
                                          bookController.selectedTime != null
                                              ? bookController.formattedTime
                                              : "Select Time",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: AppSizer().height3),

                                // Book Button
                                ElevatedButton.icon(
                                  onPressed: () {
                                    final productId = controller.product[0].id ?? "";
                                    bookController.bookTestDrive(productId);
                                  },
                                  icon: Icon(Icons.check_circle),
                                  label: Text("Book Now"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.appGreen,
                                    foregroundColor: Colors.white,
                                    minimumSize: Size(double.infinity, 48),
                                  ),
                                ),
                                SizedBox(height: 24),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  );

                },
                child: Container(
                  height: AppSizer().height6,
                  decoration: BoxDecoration(
                    color: AppColors.appGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Book for Test Drive", style: TextStyle(color: AppColors.appWhite)),
                      SizedBox(width: AppSizer().width3),
                      Icon(Icons.directions_car, color: AppColors.appWhite),
                    ],
                  ),
                ),
              ),

              SizedBox(height: AppSizer().height2,),
              InkWell(
                onTap: (){
                  Get.toNamed(AppRoutes.chat);
                },
                child: Container(
                  height: AppSizer().height6,
                  decoration: BoxDecoration(
                    color: AppColors.appGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Send Message",style: TextStyle(color: AppColors.appWhite),),
                      SizedBox(width: AppSizer().width3,),
                      Icon(Icons.message,color: AppColors.appWhite,),

                    ],
                  ),
                ),
              )


            ],
          ),
        ),
      ),
    );
  }
}