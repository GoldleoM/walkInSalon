import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple model for Discount (since it's a Map in the original code, we keep it loosely typed or could make a class)
// "change nothing else" -> keep logic same, so we keep using List<Map<String, dynamic>>
// but a class is better. Let's stick to the Map to strictly "change nothing else" in behavior/data structure if possible, 
// but using a class is much cleaner for Riverpod. 
// However, the original code used List<Map<...>>. refactoring to class might break things if I miss a usage.
// I will keep List<Map<String, dynamic>> to be safe and minimize diffs.

class DiscountsNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() {
    return [
      {
        "title": "10% Off Haircuts",
        "description": "Enjoy 10% off all haircut services this week!",
        "percentage": 10,
        "validUntil": DateTime(2025, 10, 25),
      },
      {
        "title": "20% Off Beard Trims",
        "description": "Exclusive offer for first-time customers.",
        "percentage": 20,
        "validUntil": DateTime(2025, 10, 15),
      },
    ];
  }

  void addDiscount(Map<String, dynamic> discount) {
    state = [...state, discount];
  }

  void updateDiscount(int index, Map<String, dynamic> discount) {
    final newState = [...state];
    newState[index] = discount;
    state = newState;
  }

  void removeDiscount(int index) {
    final newState = [...state];
    newState.removeAt(index);
    state = newState;
  }
}

final discountsProvider = NotifierProvider<DiscountsNotifier, List<Map<String, dynamic>>>(DiscountsNotifier.new);
