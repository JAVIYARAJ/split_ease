import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/core/routing/navigation_service.dart';
import 'package:split_ease/core/theme/app_colors.dart';
import 'package:split_ease/core/theme/app_color_tokens.dart';
import '../../domain/entities/advertisement_entity.dart';

class AppAdvertisementDialog extends StatelessWidget {
  final List<AdvertisementEntity> advertisements;
  final ValueNotifier<int> _currentIndexNotifier;
  final PageController _pageController;

  AppAdvertisementDialog({
    super.key,
    required this.advertisements,
  })  : _currentIndexNotifier = ValueNotifier<int>(0),
        _pageController = PageController();

  static Future<void> show(BuildContext context, List<AdvertisementEntity> advertisements) {
    if (advertisements.isEmpty) return Future.value();
    return showDialog(
      context: context,
      barrierDismissible: true,
      useSafeArea: false, // Ensures dark backdrop covers system status bar area completely
      barrierColor: Colors.black.withValues(alpha: 0.82),
      builder: (context) => AppAdvertisementDialog(advertisements: advertisements),
    );
  }

  void _onCtaPressed(BuildContext context, AdvertisementEntity ad) {
    Navigator.of(context).pop();
    if (ad.ctaUrl != null && ad.ctaUrl!.isNotEmpty) {
      final route = ad.ctaUrl!;
      if (route.startsWith('/')) {
        NavigationService.pushNamed(route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ads = advertisements;
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: SafeArea(
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: size.height * 0.74,
                maxWidth: 400,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).ext.surface,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: 40,
                    spreadRadius: 2,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        // Carousel View
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: ads.length,
                            onPageChanged: (index) {
                              _currentIndexNotifier.value = index;
                            },
                            itemBuilder: (context, index) {
                              return _buildAdCard(context, ads[index]);
                            },
                          ),
                        ),

                        // Bottom Navigation / Dots indicator bar + CTA
                        Container(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                          color: Theme.of(context).ext.surface,
                          child: ValueListenableBuilder<int>(
                            valueListenable: _currentIndexNotifier,
                            builder: (context, currentIndex, _) {
                              final currentAd = ads[currentIndex];
                              return Column(
                                children: [
                                  if (ads.length > 1) ...[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(ads.length, (index) {
                                        final isSelected = index == currentIndex;
                                        return AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeOutCubic,
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          width: isSelected ? 28 : 8,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primary
                                                : Theme.of(context).ext.border.withValues(alpha: 0.4),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  // CTA Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        gradient: const LinearGradient(
                                          colors: [
                                            AppColors.primaryTeal,
                                            AppColors.primary,
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.4),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () => _onCtaPressed(context, currentAd),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                currentAd.ctaText?.isNotEmpty == true
                                                    ? currentAd.ctaText!
                                                    : "Explore Now",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    // Top Bar Controls (Badge + Page counter + Close button)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Badge / Counter
                          ValueListenableBuilder<int>(
                            valueListenable: _currentIndexNotifier,
                            builder: (context, currentIndex, _) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.stars_rounded,
                                      color: AppColors.brandYellow,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      ads.length > 1
                                          ? "${currentIndex + 1} of ${ads.length}"
                                          : "FEATURED",
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          // Close (X) Button
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdCard(BuildContext context, AdvertisementEntity ad) {
    return Column(
      children: [
        // Fixed 16:9 Aspect Ratio Banner Header to prevent image distortion/cropping
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: ad.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.campaign_rounded,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              // Soft gradient overlay blending into surface color
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                        Theme.of(context).ext.surface.withValues(alpha: 0.7),
                        Theme.of(context).ext.surface,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.45, 0.85, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Title and Description Content Area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad.title,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).ext.textPrimary,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                if (ad.description != null && ad.description!.isNotEmpty) ...[
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        ad.description!,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).ext.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
