import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  void _onTapBottomNav(int index) {
    widget.navigationShell.goBranch(index, initialLocation: true);
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _onTapBottomNav,
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.currentIndex, this.onTap});
  final int currentIndex;
  final void Function(int)? onTap;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      enableFeedback: false,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      selectedLabelStyle: const TextStyle(fontFamily: 'Poppins'),
      unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins'),
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ""),
        BottomNavigationBarItem(
          icon: const Icon(Icons.shopping_cart_outlined),

          label: "",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
      ],
    );
  }
}
