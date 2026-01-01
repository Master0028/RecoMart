import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
          onNavigationRequest: (NavigationRequest request) async {
            if (!request.url.startsWith('http') && !request.url.startsWith('https')) {
              if (await canLaunchUrl(Uri.parse(request.url))) {
                await launchUrl(Uri.parse(request.url), mode: LaunchMode.externalApplication);
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (String url) {
            if (url.contains('vnp_ResponseCode')) {
              final uri = Uri.parse(url);
              final responseCode = uri.queryParameters['vnp_ResponseCode'];

              if (responseCode == '00') {
                Navigator.pop(context, true);
              } else {
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
      appBar: AppBar(
        title: const Text("VNPay Payment"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}