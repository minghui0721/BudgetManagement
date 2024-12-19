import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:wise/config/app.dart';
import 'package:wise/config/colors.dart';
import 'package:wise/helper/DateTimeHelper.dart';
import 'package:wise/models/Advertisement.dart';
import 'package:wise/providers/AdvertismentProvider.dart';

class AdvertisementSlider extends StatelessWidget {
  static String? lastShownAdId; // Track last shown ad ID for the session

  AdvertisementSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final advertisementProvider = Provider.of<AdvertisementProvider>(context);
    final advertisements = advertisementProvider.advertisements
        .where((advertisement) =>
            advertisement.startAt.isBefore(DateTimeHelper.now) &&
            advertisement.endAt.isAfter(DateTimeHelper.now))
        .toList();

    if (advertisements.isEmpty) {
      return Container();
    }

    // Filter out the last shown ad to avoid repetition in the same session
    final availableAds = advertisements.where((ad) => ad.id != lastShownAdId).toList();
    if (availableAds.isEmpty) return Container(); // If no new ad is available, do nothing

    availableAds.shuffle(Random());
    final Advertisement randomAd = availableAds.first;
    lastShownAdId = randomAd.id; // Set the ID of the ad being shown

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAdDialog(context, randomAd);
    });

    return Container();
  }

  void _showAdDialog(BuildContext context, Advertisement ad) {
    List<String> validImages = ad.images
        .where((imageUrl) => imageUrl != App.newtWorkImageNotFound)
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.primary,
          contentPadding: EdgeInsets.all(16.0),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${ad.merchantName} - ${ad.adsTitle}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200.0,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: CarouselSlider.builder(
                    options: CarouselOptions(
                      height: 250.0,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      viewportFraction: validImages.length > 1 ? 0.6 : 1.0,
                    ),
                    itemCount: validImages.length,
                    itemBuilder: (BuildContext context, int index, int realIndex) {
                      return GestureDetector(
                        onTap: () => _showFullScreenImage(context, validImages, index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Image.network(
                            validImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFullScreenImage(BuildContext context, List<String> images, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewGallery(
          pageOptions: images.map((image) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(image),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          }).toList(),
          enableRotation: true,
          onPageChanged: (index) {},
        ),
      ),
    );
  }
}