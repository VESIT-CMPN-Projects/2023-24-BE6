// import 'package:deliveryx/Users/Users_screen/Sender/homepage.dart';
// import 'package:deliveryx/Users/Users_screen/Sender/my_orders_sender.dart';
// import 'package:deliveryx/Users/Users_screen/Sender/message_sender.dart';
// import 'package:deliveryx/Users/Users_screen/Sender/profilepage.dart';
// import 'package:deliveryx/Users/Users_screen/Traveller/maps/map_controller.dart';
// import 'package:deliveryx/Users/Users_screen/Traveller/message_traveller.dart';
// import 'package:deliveryx/Users/Users_screen/Traveller/profilepage_traveller.dart';
// import 'package:deliveryx/Users/Users_screen/Traveller/testscreen.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/maps/map_view.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/current_user_location.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/profilepage_traveller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:deliveryx/Users/Users_screen/Traveller/homepage.dart';
import '../../../services/auth.dart';
import '../../../services/firestore.dart';

import '../eventlogger.dart';

class MainTraveller extends StatefulWidget {
  // MainTraveller({required this.getIndex, super.key});
  const MainTraveller({Key? key, required this.getIndex}) : super(key: key);
  final int getIndex;

  @override
  State<MainTraveller> createState() => _MainTravellerState();
}

class _MainTravellerState extends State<MainTraveller>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  int selectedIndex = 0;
  bool allowNavigation = false;
 final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.getIndex;
    tabController = TabController(length: 3, vsync: this);
    tabController!.index = widget.getIndex;
    //  // Log the event
    //     DateTime timestamp = DateTime.now();
    //     EventLogger.logHomepageEvent(
    //       'low',
    //       timestamp.toString(),
    //       1,
    //       'traveler',
    //       'HomepageStarted',
    //       'Traveler Homepage Started',
    //       {'travlerid': user?.uid},
    //     );
  }

  getSelectedIndex(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: tabController,
              children: const [
                HomePage(),
                // LocationView(),
                GetUserCurrentLocationScreen(),
                ProfilepageTraveler(),
                // FindFriends(),
                // Profilepage_Sender(),
              ]),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
            // useLegacyColorScheme: true,

            onTap: (index) async {
              setState(() {
                selectedIndex = index;
                tabController!.index = selectedIndex;
              });

              final user = await _authService.getCurrentUser();

              final userData = await _firestoreService.getUserData();

              // Log the event based on the selected index

              if (userData != null) {
                final role = userData["role"];
                DateTime timestamp = DateTime.now();
                String eventName;
                String objectName;
                switch (index) {
                  case 0:
                    eventName = 'HomepageNavigation';
                    objectName = 'b_HomeNavigation';
                    break;
                  case 1:
                    eventName = 'MapsNavigation';
                    objectName = 'b_MapsNavigation';
                    break;
                  case 2:
                    eventName = 'ProfileNavigation';
                    objectName = 'b_ProfileNavigation';
                    break;
                  default:
                    eventName = '';
                    objectName = '';
                }
                EventLogger.logHomepageEvent(
                  'low',
                  timestamp.toString(),
                  role,
                  objectName,
                  eventName,
                  '$eventName button clicked',
                  {'travelerid': user?.uid,'role':role},
                );
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.darkgrey,
            selectedFontSize: 14,
            // unselectedFontSize: 14,
            items: [
              BottomNavigationBarItem(
                activeIcon: Icon(
                  Icons.home,
                  color: AppColors.primary,
                ),
                icon: Icon(
                  Icons.home_outlined,
                  color: AppColors.darkgrey,
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                ),
                icon: Icon(
                  Icons.location_on_outlined,
                  color: AppColors.darkgrey,
                ),
                label: "Map",
              ),
              BottomNavigationBarItem(
                activeIcon: Icon(
                  // Icons.message,
                  Icons.account_circle,
                  color: AppColors.primary,
                ),
                icon: Icon(
                  // Icons.message_outlined,
                  Icons.account_circle_outlined,
                  color: AppColors.darkgrey,
                ),
                label: "Profile",
              ),
            ],
          ),
        ),
        onWillPop: () async {
          if (allowNavigation) {
            return true; // Allow navigation
          } else {
            if (tabController!.index == 0) {
              // Use SystemNavigator to exit the app.
              // SystemNavigator.pop();
              // return false; // Returning false to prevent default back button behavior.
              bool confirmed = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Confirm Exit'),
                    content: const Text('Do you really want to exit the app?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('No'),
                        onPressed: () {
                          Navigator.of(context)
                              .pop(false); // Don't allow navigation
                        },
                      ),
                      TextButton(
                        child: const Text('Yes'),
                        onPressed: () {
                          SystemNavigator.pop();
                        },
                      ),
                    ],
                  );
                },
              );

              return confirmed;
            } else {
              setState(() {
                tabController!.index = 0;
                selectedIndex = 0;
              });
              return false;
            }
          }
        });
  }
}
