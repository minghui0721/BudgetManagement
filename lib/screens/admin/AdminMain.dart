import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/helper/FetchDataHelper.dart';
import 'package:wise/providers/AdvertismentProvider.dart';
import 'package:wise/providers/BankProvider.dart';
import 'package:wise/providers/FinancialAdvisorProvider.dart';
import 'package:wise/providers/NotificationProvider.dart';
import 'package:wise/providers/SpendingCategoryProvider.dart';
import 'package:wise/providers/TermAndConditionProvider.dart';
import 'package:wise/providers/UserProvider.dart';
import 'package:wise/screens/admin/advertisement/index.dart';
import 'package:wise/screens/admin/components/BottomNavBar.dart';
import 'package:wise/screens/admin/view/content/index.dart';
import 'package:wise/screens/admin/view/create/index.dart';
import 'package:wise/screens/admin/view/dashboard/index.dart';
import 'package:wise/screens/admin/view/profile/index.dart';

class AdminMain extends StatefulWidget {
  final int currentIndex;

  const AdminMain({Key? key, this.currentIndex = 0}) : super(key: key);

  @override
  _AdminMainState createState() => _AdminMainState();
}

class _AdminMainState extends State<AdminMain> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _onRefresh() async {
    await Provider.of<FinancialAdvisorProvider>(context, listen: false)
        .fetchAllFinancialAdvisors();

    await Provider.of<BankProvider>(context, listen: false).fetchAllBanks();

    await Provider.of<UserProvider>(context, listen: false)
        .fetchAllUsers();

    await Provider.of<AdvertisementProvider>(context, listen: false)
        .fetchAllAdvertisments();

    await Provider.of<NotificationProvider>(context, listen: false)
        .fetchAllNotifications();

    await Provider.of<SpendingCategoryProvider>(context, listen: false)
        .fetchAllCategories();

    await Provider.of<TermAndConditionProvider>(context, listen: false)
        .fetchAllTermsAndConditions();
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return AdminDashboard();
      case 1:
        return AdminContent();
      case 2:
        return AdminCreate();
      case 3:
        return AdvertisementsScreen();
      case 4:
        return AdminProfile();
      default:
        return AdminDashboard();
    }
  }

  Future<bool> _onWillPop() async {
    // Close the app
    SystemNavigator.pop();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.mediumGray,
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: _getSelectedPage(),
            ),
          ),
        ),
        bottomNavigationBar: SizedBox(
          child: BottomNavBar(
            currentIndex: _selectedIndex,
            onTap: _onBottomNavTap,
          ),
        ),
      ),
    );
  }
}
