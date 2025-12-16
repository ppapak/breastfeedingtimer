
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kWeeklySubscriptionId = 'weekly_subscription';
const List<String> _kProductIds = <String>[
  _kWeeklySubscriptionId,
];

class PurchaseProvider with ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  bool _isSubscribed = false;
  bool get isSubscribed => _isSubscribed;

  DateTime? _trialStartDate;
  bool _isTrialAvailable = false;
  bool get isTrialAvailable => _isTrialAvailable;

  PurchaseProvider() {
    initialize();
  }

  Future<void> initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (available) {
      await _loadProducts();
      await _checkSubscriptionStatus();
      _subscription = _inAppPurchase.purchaseStream.listen(
        (List<PurchaseDetails> purchaseDetailsList) {
          _listenToPurchaseUpdated(purchaseDetailsList);
        },
        onDone: () {
          _subscription.cancel();
        },
        onError: (Object error) {
          // handle error here.
        },
      );
    }
  }

  Future<void> _loadProducts() async {
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (response.notFoundIDs.isNotEmpty) {
      // Handle missing products.
    }
    _products = response.productDetails;
    notifyListeners();
  }

  Future<void> _checkSubscriptionStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> purchased = prefs.getStringList('purchases') ?? [];
    _isSubscribed = purchased.contains(_kWeeklySubscriptionId);

    if (!_isSubscribed) {
      final int? trialStartDateMillis = prefs.getInt('trialStartDate');
      if (trialStartDateMillis == null) {
        _isTrialAvailable = true;
      } else {
        _trialStartDate = DateTime.fromMillisecondsSinceEpoch(trialStartDateMillis);
        final bool trialHasExpired = DateTime.now().difference(_trialStartDate!).inDays >= 7;
        if (trialHasExpired) {
          _isTrialAvailable = false;
          _isSubscribed = false;
        } else {
          // Trial is active
          _isSubscribed = true;
        }
      }
    }
    notifyListeners();
  }

  Future<void> _savePurchase(String productId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> purchased = prefs.getStringList('purchases') ?? [];
    if (!purchased.contains(productId)) {
        purchased.add(productId);
        await prefs.setStringList('purchases', purchased);
    }
    _isSubscribed = true;
    notifyListeners();
  }

  void _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI.
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle error.
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _savePurchase(purchaseDetails.productID);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> purchaseSubscription() async {
    if (_products.isEmpty) {
        // Products not loaded yet
        return;
    }
    final ProductDetails productDetails =
        _products.firstWhere((element) => element.id == _kWeeklySubscriptionId);
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> startTrial() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _trialStartDate = DateTime.now();
    await prefs.setInt('trialStartDate', _trialStartDate!.millisecondsSinceEpoch);
    _isTrialAvailable = false;
    _isSubscribed = true; // Trial is a form of subscription
    notifyListeners();
  }
}
