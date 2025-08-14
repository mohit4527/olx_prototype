import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';

class NotificationScreen extends StatelessWidget {
   NotificationScreen({super.key});

  final List<Map<String, String>> notifications = [
    {
      "title": "New Message",
      "subtitle": "You have a new message from seller.",
      "time": "2 mins ago",
    },
    {
      "title": "Offer Accepted",
      "subtitle": "Your offer was accepted. Contact the seller.",
      "time": "10 mins ago",
    },
    {
      "title": "Item Delivered",
      "subtitle": "Your item has been delivered successfully.",
      "time": "1 hour ago",
    },
    {
      "title": "Reminder",
      "subtitle": "Don't forget to check out new listings!",
      "time": "Yesterday",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.appGreen,
        title: Text(
          "Notifications",
          style: TextStyle(
            fontSize: AppSizer().fontSize18,
            color: AppColors.appWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(onPressed: (){
          Get.back();
        }, icon:
        Icon(Icons.arrow_back,color: AppColors.appWhite,)),
      ),
      body: Container(
         height: AppSizer().height100,
         decoration: BoxDecoration(
           gradient: LinearGradient(
           colors: AppColors.appGradient,
           begin: Alignment.topLeft,
           end: Alignment.bottomRight,
         ),
         ),
    child:
      ListView.separated(
        padding: EdgeInsets.all(AppSizer().height2),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => Divider(color: AppColors.appGrey.shade700),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: AppSizer().height2),
            leading: CircleAvatar(
              radius: AppSizer().height3,
              backgroundColor: AppColors.appBlack.withOpacity(0.5),
              child: Icon(Icons.notifications_active, color: AppColors.appWhite),
            ),
            title: Text(
              notif['title']!,
              style: TextStyle(
                fontSize: AppSizer().fontSize17,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              notif['subtitle']!,
              style: TextStyle(
                fontSize: AppSizer().fontSize14,
                color: AppColors.appGrey.shade700,
              ),
            ),
            trailing: Text(
              notif['time']!,
              style: TextStyle(
                fontSize: AppSizer().fontSize14,
                color: AppColors.appGrey.shade700,
              ),
            ),
          );
        },
      ),
      )
    );
  }
}
