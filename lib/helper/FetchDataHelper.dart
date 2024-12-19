import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/providers/AdvertismentProvider.dart';
import 'package:wise/providers/BankProvider.dart';
import 'package:wise/providers/FinancialAdvisorProvider.dart';
import 'package:wise/providers/NotificationProvider.dart';
import 'package:wise/providers/SpendingCategoryProvider.dart';
import 'package:wise/providers/TermAndConditionProvider.dart';
import 'package:wise/providers/UserProvider.dart';

class FetchDataHelper {
  static Future<void> fetchData(BuildContext context) async {
    final bankProvider = Provider.of<BankProvider>(context, listen: false);
    final financialAdvisorProvider =
        Provider.of<FinancialAdvisorProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final advertisementProvider =
        Provider.of<AdvertisementProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    final spendingCategoryProvider =
        Provider.of<SpendingCategoryProvider>(context, listen: false);
    final termAndConditionProvider =
        Provider.of<TermAndConditionProvider>(context, listen: false);

    try {
      await Future.wait([
        bankProvider.fetchAllBanks(),
        financialAdvisorProvider.fetchAllFinancialAdvisors(),
        userProvider.fetchAllUsers(),
        advertisementProvider.fetchAllAdvertisments(),
        notificationProvider.fetchAllNotifications(),
        spendingCategoryProvider.fetchAllCategories(),
        termAndConditionProvider.fetchAllTermsAndConditions(),
      ]);

    } catch (e) {
      print("Error fetching data: $e");
    }
  }
}