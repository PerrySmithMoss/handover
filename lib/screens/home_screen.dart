import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:handover_app/models/user_model.dart';
import 'package:handover_app/provider/user_data.dart';
import 'package:handover_app/screens/ENCRYPTION_TEST.dart';
import 'package:handover_app/screens/activity_screen.dart';
import 'package:handover_app/screens/create_post_screen.dart';
import 'package:handover_app/screens/feed_screen.dart';
import 'package:handover_app/screens/patients_screen.dart';
import 'package:handover_app/screens/profile_screen.dart';
import 'package:handover_app/screens/search_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {

  final String currentUserId;

  HomeScreen({this.currentUserId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  User user;
  int _currentTab = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = Provider.of<UserData>(context).currentUserId;
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          FeedScreen(currentUserId: currentUserId),
          Encryption(),
          PatientsScreen(userId: currentUserId),
          SearchScreen(),
          CreatePostScreen(),
          ActivityScreen(currentUserId: currentUserId),
          ProfileScreen(currentUserId: currentUserId, 
          userId: currentUserId,
          ),
        ],
        onPageChanged: (int index) {
          setState(() {
            _currentTab = index;
          });
        },
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _currentTab,
        onTap: (int index) {
          setState(() {
            _currentTab = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        },
        activeColor: Colors.black,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home,size: 32)),
          BottomNavigationBarItem(icon: Icon(Icons.enhanced_encryption,size: 32)),
          BottomNavigationBarItem(icon: Icon(Icons.list, size: 40)),
          BottomNavigationBarItem(icon: Icon(Icons.search, size: 32)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera, size: 32)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications, size: 32)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle, size: 32))
        ],
      ),
    );
  }
}
