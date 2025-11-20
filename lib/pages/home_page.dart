import 'package:flutter/material.dart';
import 'package:tes/Widget/post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isSearchVisible = true;
  double _lastScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentScrollOffset = _scrollController.offset;
    final scrollDelta = currentScrollOffset - _lastScrollOffset;

    // Show search when scrolling up, hide when scrolling down
    if (scrollDelta > 0 && _isSearchVisible) {
      // Scrolling down - hide search
      setState(() {
        _isSearchVisible = false;
      });
    } else if (scrollDelta < 0 && !_isSearchVisible) {
      // Scrolling up - show search
      setState(() {
        _isSearchVisible = true;
      });
    }

    _lastScrollOffset = currentScrollOffset;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              toolbarHeight: _isSearchVisible ? screenHeight * 0.10 : 0,
              backgroundColor: Colors.white,
              flexibleSpace: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: _isSearchVisible ? screenHeight * 0.10 : 0,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: _isSearchVisible ? 1.0 : 0.0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0x80E3E3E3),
                        hintText: 'Cari...',
                        prefixIcon: Icon(Icons.search),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => PostCard(
                  user: 'Username',
                  text: 'MUAHAHAHHHAHAHAHAHAHHAHAHHAHAHAHAHAHAHAHHAA',
                  like: 20,
                  image: 'assets/images/large_rocket_logo.png',
                  screenwidth: screenWidth,
                ),
                childCount: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}