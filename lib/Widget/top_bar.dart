import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class TopBar extends StatelessWidget {
  final String title;
  final double screenSize;
  final List<Widget>? actions;

  bool? transparent; //nullable, Optional

  final bool pin; //optional
  final bool floating; //optional
  final bool showBack; //optional

  TopBar({
    super.key,
    required this.title,
    required this.screenSize,

    this.showBack = true,
    this.transparent,
    this.pin = true,
    this.actions,
    this.floating = true,
  });

  // Cara pakai:
  // TopBar(title: "Profile", showBack: false, transparent: true, screenSize: screenSize, pin: false, floating: false),
  // Penjelasan: Jika pin / floating tidak didefinisikan kedalam func call, otomatis true
  // Jika ingin pin / floating tidak true, beri nilai didalam function call

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: floating,
      pinned: pin,
      backgroundColor:
          // Jika ingin transparent, gunakan parameter transparent
          transparent != null && transparent == true ?
      Colors.transparent : Colors.white,
      elevation: 1,
      automaticallyImplyLeading: false,

      leading: showBack
          ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => GoRouter.of(context).pop(),
        // onPressed: () => Navigator.pop(context),
      )
          : null,

      title: Text(
        title,
        style: TextStyle(
          fontSize: screenSize * 0.05,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
      actions: actions,
    );
  }
}
