import 'package:flutter/material.dart';
import 'package:forest_guard/src/ui/call_authorities%20_view/call_authorities_view.dart';
import 'package:forest_guard/src/ui/home_view/home_view.dart';
import 'package:forest_guard/src/ui/verified_trucks_view/verified_trucks_view.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:svg_flutter/svg.dart';
import 'package:svg_flutter/svg_flutter.dart';

class InitialView extends StatefulWidget {
  const InitialView({super.key});

  @override
  State<InitialView> createState() => _InitialViewState();
}

class _InitialViewState extends State<InitialView> {
  final String assetName = 'assets/images/truck.svg';

  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [
    const HomeView(),
    const VerifiedTrucksView(),
    const CallAuthorities()
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Widget svg = SvgPicture.asset(
      assetName,
      semanticsLabel: 'truck',
      colorFilter: ColorFilter.mode(colorScheme.onPrimary, BlendMode.srcIn),
      width: 100,
      height: 80,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      allowDrawingOutsideViewBox: false,
      matchTextDirection: false,
      clipBehavior: Clip.hardEdge,
      placeholderBuilder: (BuildContext context) =>
          const CircularProgressIndicator(),
    );
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(children: [
          Text('Forest Guard',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary)),
          Text(
            'Protecting Romania\'s forests, one Truck at a time.',
            style: TextStyle(fontSize: 15, color: colorScheme.onPrimary),
          )
        ]),
        backgroundColor: colorScheme.primary,
        centerTitle: true,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: SafeArea(
        child: GNav(
          backgroundColor: colorScheme.primary,
          rippleColor: colorScheme.surfaceVariant,
          gap: 8,
          activeColor: colorScheme.surface,
          iconSize: 80,
          duration: const Duration(milliseconds: 300),
          tabBackgroundColor: Colors.black54,
          color: colorScheme.surface,
          tabs: [
            const GButton(
              icon: Icons.camera_alt,
              text: 'Detect',
            ),
            GButton(
              leading: svg,
              icon: Icons.fire_extinguisher, // Use a transparent icon
              text: 'Verified Trucks',
            ),

            //! Not implemented yet
            // GButton(
            //   icon: Icons.emergency,
            //   text: '112',
            // )
          ],
          selectedIndex: _selectedIndex,
          onTabChange: _onItemTap,
        ),
      ),
    );
  }
}
