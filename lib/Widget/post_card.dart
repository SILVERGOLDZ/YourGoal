import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//TODO: Make Clickable like button
//TODO: Make Clickable bookmark button
//TODO: Make Clickable Profile image
//TODO: Visit world button

class PostCard extends StatelessWidget{
  //final Image user_profile_image
  final String user;
  final String text;
  final int like;
  final String? image;

  PostCard({
    super.key,
    //TODO: tambah profil image
    //required this.user_profile_image,
    required this.user,
    required this.text,
    required this.like,
    this.image,
  });

  @override
  Widget build(BuildContext context){
    return Card.filled(
      color: Color(0xFFFFFFFF),
      // elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Profile Row
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  //TODO: Add image
                  backgroundImage: AssetImage('assets/profile.jpg'),
                ),
                SizedBox(width: 10),
                Text(
                  user,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),

            SizedBox(height: 10),

            // Post Text
            Text(
              text,
              style: TextStyle(fontSize: 15),
            ),

            SizedBox(height: 30),

            // cek image ada diupload di posting atau tidak
            if (image != null)...[
              Image.asset(image!, width: double.infinity,),
              SizedBox(height: 30),
            ]
            else
              SizedBox.shrink(),

            // Bottom Icons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.thumb_up_alt_outlined, size: 24),
                      SizedBox(width: 6),
                      Text('$like'),
                    ],
                  ),
                  Icon(Icons.bookmark_border, size: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}