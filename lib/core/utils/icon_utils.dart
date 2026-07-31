import 'package:flutter/material.dart';

class IconUtils {
  static IconData getIconFromString(String iconName) {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant_rounded;
      case 'flight': return Icons.flight_rounded;
      case 'directions_car': return Icons.directions_car_rounded;
      case 'local_gas_station': return Icons.local_gas_station_rounded;
      case 'shopping_bag': return Icons.shopping_bag_rounded;
      case 'shopping_cart': return Icons.shopping_cart_rounded;
      case 'movie': return Icons.movie_rounded;
      case 'local_movies': return Icons.local_movies_rounded;
      case 'home': return Icons.home_rounded;
      case 'apartment': return Icons.apartment_rounded;
      case 'receipt_long': return Icons.receipt_long_rounded;
      case 'medical_services': return Icons.medical_services_rounded;
      case 'school': return Icons.school_rounded;
      case 'sports_cricket': return Icons.sports_cricket_rounded;
      case 'celebration': return Icons.celebration_rounded;
      case 'card_giftcard': return Icons.card_giftcard_rounded;
      case 'pets': return Icons.pets_rounded;
      case 'payments': return Icons.payments_rounded;
      case 'trending_up': return Icons.trending_up_rounded;
      case 'shield': return Icons.shield_rounded;
      case 'build': return Icons.build_rounded;
      case 'business_center': return Icons.business_center_rounded;
      case 'local_laundry_service': return Icons.local_laundry_service_rounded;
      case 'subscriptions': return Icons.subscriptions_rounded;
      case 'smartphone': return Icons.smartphone_rounded;
      case 'wifi': return Icons.wifi_rounded;
      case 'bolt': return Icons.bolt_rounded;
      case 'water_drop': return Icons.water_drop_rounded;
      case 'account_balance': return Icons.account_balance_rounded;
      case 'volunteer_activism': return Icons.volunteer_activism_rounded;
      case 'family_restroom': return Icons.family_restroom_rounded;
      case 'group': return Icons.group_rounded;
      case 'work': return Icons.work_rounded;
      case 'person': return Icons.person_rounded;
      case 'credit_card': return Icons.credit_card_rounded;
      case 'account_balance_wallet': return Icons.account_balance_wallet_rounded;
      case 'savings': return Icons.savings_rounded;
      case 'beach_access': return Icons.beach_access_rounded;
      case 'hotel': return Icons.hotel_rounded;
      case 'local_taxi': return Icons.local_taxi_rounded;
      case 'train': return Icons.train_rounded;
      case 'directions_bus': return Icons.directions_bus_rounded;
      case 'flight_takeoff': return Icons.flight_takeoff_rounded;
      case 'coffee': return Icons.coffee_rounded;
      case 'fastfood': return Icons.fastfood_rounded;
      case 'wine_bar': return Icons.wine_bar_rounded;
      case 'child_care': return Icons.child_care_rounded;
      case 'checkroom': return Icons.checkroom_rounded;
      case 'devices': return Icons.devices_rounded;
      case 'chair': return Icons.chair_rounded;
      case 'spa': return Icons.spa_rounded;
      case 'qr_code': return Icons.qr_code_rounded;
      case 'qr_code_scanner': return Icons.qr_code_scanner_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
