import 'package:deliveryx/Users/Users_screen/Traveller/profilepage_traveller.dart';
import 'package:deliveryx/util/colors.dart';
import 'package:flutter/material.dart';

class MessageTraveller extends StatefulWidget {
  const MessageTraveller({super.key});

  @override
  State<MessageTraveller> createState() => _MessageTravellerState();
}

class _MessageTravellerState extends State<MessageTraveller> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //     backgroundColor: AppColors.primary, title: const Text("Inbox")),
      body: Container(
        child: Column(children: [
          Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(color: AppColors.header),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Inbox",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          )),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ProfilepageTraveler()), // Replace 'AnotherPage()' with the page you want to navigate to
                          );
                        },
                        child: const Image(
                          image: AssetImage(
                              "assets/third-party_images/icons/user.png"),
                          width: 50,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),

                  //Search messages
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      color: AppColors.primary,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          const Icon(Icons.search),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Search Messages",
                                  hintStyle: TextStyle(
                                    color: AppColors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const Icon(Icons.message),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  width: 16,
                ),
                Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(64),
                      image: const DecorationImage(
                          image: AssetImage(
                              'assets/third-party_images/icons/user.png'),
                          fit: BoxFit.fitWidth),
                    )),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    // mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Maddy Lin',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: AppColors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                height: 1.5),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              '3:74 Pm',
                              style: TextStyle(
                                color: AppColors.black,
                                fontFamily: 'Abhaya Libre Medium',
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        'Hi Alex, I’m on the way to your location, be ready to collect',
                        style: TextStyle(
                          color: AppColors.darkgrey,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
