import 'package:flutter/material.dart';
import '../constants/app_sizer.dart';

class SocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final String name;
  final String iconpath;

  const SocialButton({
    Key? key,
    required this.onTap,
    required this.name,
    required this.iconpath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: AppSizer().height5,
        width: MediaQuery.sizeOf(context).width/3,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(20),
        ),
        child:Row(
          children: [
            Image.asset(iconpath,height: 20,),
            SizedBox(width: AppSizer().width3,),
            Text(name,style:TextStyle(fontWeight: FontWeight.w600,fontSize: AppSizer().fontSize16),)
          ],
        )
      ),
    );
  }
}