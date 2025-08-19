import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';

class MyAidsScreen extends StatelessWidget {
  const MyAidsScreen({super.key});

  final List<Map<String, String>> aidsList = const [
    {
      "title": "Financial Aid",
      "description": "Short-term loan available for students.",
      "expiry": "Expires: 20 Sep 2025",
      "contact": "7270095618"
    },
    {
      "title": "Medical Aid",
      "description": "Free health checkup camp in your area.",
      "expiry": "Expires: 25 Sep 2025",
      "contact": "9876543210"
    },
    {
      "title": "Education Aid",
      "description": "Scholarship for diploma students.",
      "expiry": "Expires: 30 Sep 2025",
      "contact": "9123456780"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.appGreen,
        title: Text(
          "My Aids",
          style: TextStyle(color: AppColors.appWhite, fontSize: AppSizer().fontSize18),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: AppColors.appWhite),
        ),
      ),
      body:Container(
      height:AppSizer().height100,
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: AppColors.appGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    ),
    ),
    child:
      Padding(
        padding: EdgeInsets.all(AppSizer().width3),
        child: ListView.builder(
          itemCount: aidsList.length,
          itemBuilder: (context, index) {
            final aid = aidsList[index];
            return Container(
              margin: EdgeInsets.only(bottom: AppSizer().height2),
              padding: EdgeInsets.all(AppSizer().height1),
              decoration: BoxDecoration(
                color: AppColors.appWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aid["title"] ?? "",
                    style: TextStyle(
                      fontSize:AppSizer().fontSize17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.appGreen,
                    ),
                  ),
                  SizedBox(height: AppSizer().height1),
                  Text(
                    aid["description"] ?? "",
                    style: TextStyle(
                      fontSize:AppSizer().fontSize15,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: AppSizer().height1),
                  Text(
                    aid["expiry"] ?? "",
                    style: TextStyle(
                      fontSize:AppSizer().fontSize15,
                      color: Colors.redAccent,
                    ),
                  ),
                  SizedBox(height: AppSizer().height3),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // call function yaha API se ya phone dialer khulega
                        Get.snackbar("Calling", "Dialing ${aid["contact"]}");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.call, color: Colors.white),
                      label: const Text(
                        "Call Now",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
      ),
    );
  }
}