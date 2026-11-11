import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'pro_service.dart';

class PurchaseService {
  static const String proProductId = 'wanalab_pro_499';
  
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  void init() {
    _subscription = _iap.purchaseStream.listen((purchases) {
      for (var purchase in purchases) {
        if (purchase.productID == proProductId) {
          if (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) {
            ProService.setPro(true);
          }
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
        }
      }
    }, onError: (e) {
      print("Purchase error: $e");
    });
  }

  void dispose() {
    _subscription.cancel();
  }

  Future<void> buyPro() async {
    final available = await _iap.isAvailable();
    if (!available) {
      print("Store not available");
      return;
    }

    final response = await _iap.queryProductDetails({proProductId});
    if (response.productDetails.isEmpty) {
      print("Product not found: $proProductId - Create it in Play Console");
      // For now enable pro for testing
      await ProService.setPro(true);
      return;
    }

    final product = response.productDetails.first;
    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }
}
