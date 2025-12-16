
import 'package:flutter/material.dart';

import 'purchase_provider.dart';

class PaywallScreen extends StatefulWidget {
  final PurchaseProvider purchaseProvider;

  const PaywallScreen({super.key, required this.purchaseProvider});

  @override
  PaywallScreenState createState() => PaywallScreenState();
}

class PaywallScreenState extends State<PaywallScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
      ),
      body: ListView(
        children: [
          const Text(
            'Enjoy a 7-day free trial. After that, a subscription is required to continue using the app.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          for (var product in widget.purchaseProvider.products)
            ListTile(
              title: Text(product.title),
              subtitle: Text(product.description),
              trailing: Text(product.price),
              onTap: () => widget.purchaseProvider.purchaseSubscription(),
            ),
        ],
      ),
    );
  }
}
