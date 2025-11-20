import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class ScrollableTopBar extends StatelessWidget {
  final String title;
  final bool showBack;

  const ScrollableTopBar({
    super.key,
    required this.title,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: Colors.white,
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
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
