import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class TopBar extends StatelessWidget {
  final String title;
  final bool showBack;
  bool? transparent;
  final double screenSize;
  final bool pin;
  final List<Widget>? actions;

  TopBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.transparent,
    required this.screenSize,
    this.pin = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
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
