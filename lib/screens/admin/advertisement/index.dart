import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/config/theme.dart';
import 'package:wise/helper/DateTimeHelper.dart';
import 'package:wise/models/Advertisement.dart';
import 'package:wise/providers/AdvertismentProvider.dart';
import 'package:wise/repositories/AdvertisementRepository.dart';
import 'package:wise/screens/admin/advertisement/details.dart';
import 'package:wise/screens/admin/components/AppBar.dart';
import 'package:wise/screens/admin/components/ConfirmationDialog.dart';
import 'package:wise/screens/admin/components/ItemList.dart';
import 'package:wise/screens/admin/components/SearchBar.dart';
import 'package:wise/screens/admin/components/SearchButton.dart';
import 'package:wise/screens/admin/components/TableTabBar.dart';

class AdvertisementsScreen extends StatefulWidget {
  @override
  _AdvertisementsScreenState createState() => _AdvertisementsScreenState();
}

class _AdvertisementsScreenState extends State<AdvertisementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  String searchQuery = '';
  bool showSearch = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  Widget buildAdvertisementList(List<Advertisement> items) {
    return ItemList<Advertisement>(
      items: items,
      getTitle: (advertisement) => advertisement.adsTitle,
      getImagePath: (advertisement) => advertisement.images[0],
      getDetails: (advertisement) => [
        Text('Created At: ${advertisement.createdAt}'),
        Text('Updated At: ${advertisement.updatedAt}'),
      ],
      onEdit: _edit,
      onDelete: (advertisement) => _confirmDelete(context, advertisement),
      onView: _view,
    );
  }

  void toggleSearch(bool value) {
    setState(() {
      showSearch = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final advertisementProvider = Provider.of<AdvertisementProvider>(context);

    final advertisements = advertisementProvider.advertisements
        .where((advertisement) => advertisement.adsTitle
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    int total = advertisementProvider.total;
    int inPeriod = advertisementProvider.inPeriod;
    int outPeriod = advertisementProvider.outPeriod;
    int future = advertisementProvider.future;

    return Scaffold(
      backgroundColor: AppColors.mediumGray,
      appBar: AdminAppBar(
        title: 'Advertisements',
        button: const Icon(Icons.add),
        onPressed: () => _navigateToDetails(null, isCreateMode: true),
      ),
      body: Column(
        children: [
          if (showSearch)
            WiseSearchBar(
              controller: searchController,
              focusNode: searchFocusNode,
              hintText: 'Search Advertisements by Title',
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
              onPressed: () {
                setState(() {
                  searchController.clear();
                  searchQuery = '';
                  showSearch = false;
                });
              },
            ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.mediumGray,
              ),
              child: advertisements.isEmpty
                  ? const Text(
                      "No Advertisements found.",
                      style: AppTheme.titleTextStyle,
                    )
                  : isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : TableTabBar(
                          tabTitles: [
                            'All ($total)',
                            'In Period ($inPeriod)',
                            'Out of Period ($outPeriod)',
                            'Future ($future)',
                          ],
                          tabViews: [
                            buildAdvertisementList(advertisements),
                            buildAdvertisementList(
                              advertisements
                                  .where((advertisement) =>
                                      advertisement.startAt
                                          .isBefore(DateTimeHelper.now) &&
                                      advertisement.endAt
                                          .isAfter(DateTimeHelper.now))
                                  .toList(),
                            ),
                            buildAdvertisementList(
                              advertisements
                                  .where((advertisement) => advertisement.endAt
                                      .isBefore(DateTimeHelper.now))
                                  .toList(),
                            ),
                            buildAdvertisementList(
                              advertisements
                                  .where((advertisement) =>
                                      advertisement.startAt
                                          .isAfter(DateTimeHelper.now) &&
                                      advertisement.endAt
                                          .isAfter(DateTimeHelper.now))
                                  .toList(),
                            ),
                          ],
                          tabController: _tabController,
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: SearchButton(
        heroTag: 'search',
        showSearch: showSearch,
        searchFocusNode: searchFocusNode,
        searchController: searchController,
        onSearchToggle: toggleSearch,
      ),
    );
  }

  void _confirmDelete(BuildContext context, Advertisement advertisement) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: "Confirm Delete",
          content:
              "Are you sure you want to delete this Financial advertisement?",
          confirmButtonText: "Yes",
          cancelButtonText: "No",
          onConfirm: () {
            _delete(advertisement);
          },
        );
      },
    );
  }

  void _delete(
    Advertisement advertisement,
  ) async {
    setState(() {
      isLoading = true;
    });

    try {
      AdvertisementRepository advertisementRepository =
          AdvertisementRepository();
      await advertisementRepository.delete(advertisement.id);
      await Provider.of<AdvertisementProvider>(context, listen: false)
          .fetchAllAdvertisments();
    } catch (e) {
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully deleted advertisement!')),
        );
      }
    }
  }

  void _navigateToDetails(Advertisement? advertisement,
      {bool isEditMode = false, bool isCreateMode = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdvertisementDetailsScreen(
          advertisement: advertisement,
          isEditMode: isEditMode,
          isCreateMode: isCreateMode,
        ),
      ),
    );
  }

  void _edit(Advertisement advertisement) {
    _navigateToDetails(advertisement, isEditMode: true);
  }

  void _view(Advertisement advertisement) {
    _navigateToDetails(advertisement);
  }
}