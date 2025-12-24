import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VnpayPaymentPage extends StatefulWidget {
  final String paymentUrl;
  const VnpayPaymentPage({super.key, required this.paymentUrl});

  @override
  State<VnpayPaymentPage> createState() => _VnpayPaymentPageState();
}

class _VnpayPaymentPageState extends State<VnpayPaymentPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (url.contains('vnp_ResponseCode')) {
              final uri = Uri.parse(url);
              final responseCode = uri.queryParameters['vnp_ResponseCode'];

              if (responseCode == '00') {
                print("Payment sucessfully!");
                Navigator.pop(context, true);
              } else {
                print("Payment failed!");
                Navigator.pop(context, false);
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("VNPay Payment")),
      body: WebViewWidget(controller: _controller),
    );
  }
}