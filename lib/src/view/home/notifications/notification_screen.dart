import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:path/path.dart';
import '../../../controller/notification_controller.dart';


class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});


  final notifController = Get.put(NotificationsController());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: AppColors.appWhite),
        ),
      ),
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
            colors: [AppColors.appGreen, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Obx(() {
          if (notifController.notifications.isEmpty) {
            return Center(
              child: Text(
                "No notifications yet",
                style: TextStyle(
                  fontSize: AppSizer().fontSize16,
                  color: AppColors.appWhite,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(AppSizer().height2),
            itemCount: notifController.notifications.length,
            separatorBuilder: (_, __) =>
                Divider(color: AppColors.appGrey.shade700),
            itemBuilder: (context, index) {
              final notif = notifController.notifications[index];
              return ListTile(
                contentPadding:
                EdgeInsets.symmetric(vertical: AppSizer().height2),
                leading: CircleAvatar(
                  radius: AppSizer().height3,
                  backgroundColor: AppColors.appBlack.withOpacity(0.5),
                  child: Icon(Icons.notifications_active,
                      color: AppColors.appWhite),
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
          );
        }),
      ),
    );
  }
}
