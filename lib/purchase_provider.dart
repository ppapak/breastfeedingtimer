
import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kConsumableId = 'consumable';
const String _kUpgradeId = 'upgrade';
const String _kSilverSubscriptionId = 'subscription_silver';
const String _kGoldSubscriptionId = 'subscription_gold';
const List<String> _kProductIds = <String>[
  _kConsumableId,
  _kUpgradeId,
  _kSilverSubscriptionId,
  _kGoldSubscriptionId,
];

class PurchaseProvider {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  final Set<String> _purchasedProductIds = {};

  DateTime? _trialStartDate;

  Future<void> initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (available) {
      await _loadProducts();
      await _loadPurchases();
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
  }

  Future<void> _loadPurchases() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> purchased = prefs.getStringList('purchases') ?? [];
    for (String id in purchased) {
      _purchasedProductIds.add(id);
    }
  }

  Future<void> _savePurchase(String productId) async {
    _purchasedProductIds.add(productId);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('purchases', _purchasedProductIds.toList());
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

  Future<void> purchaseProduct(String productId) async {
    final ProductDetails productDetails =
        _products.firstWhere((element) => element.id == productId);
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
  }

  bool isProductPurchased(String productId) {
    return _purchasedProductIds.contains(productId);
  }

  Future<void> startTrial() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _trialStartDate = DateTime.now();
    await prefs.setInt('trialStartDate', _trialStartDate!.millisecondsSinceEpoch);
  }

  Future<bool> isTrialActive() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? trialStartDateMillis = prefs.getInt('trialStartDate');
    if (trialStartDateMillis == null) {
      return false;
    }
    _trialStartDate = DateTime.fromMillisecondsSinceEpoch(trialStartDateMillis);
    return DateTime.now().difference(_trialStartDate!).inDays < 7;
  }
}
