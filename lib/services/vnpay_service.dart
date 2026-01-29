import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:recomart/constants.dart';

class VnpayService {
  static const String vnpVersion = '2.1.0';
  static const String vnpCommand = 'pay';
  static const String vnpTmnCode = 'Y1HS43HN';
  static const String vnpHashSecret = 'LRLG4KNISR73DY7KNZY9DLA1JTQVOP0V';
  static const String vnpUrl = 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
  static const String vnpReturnUrl = 'https://lordlier-nonmaritally-margrett.ngrok-free.dev/vnpay_return';
  //static String get vnpReturnUrl => '${AppConstants.baseUrl}/vnpay_return';

  String generatePaymentUrl({required String orderId, required double amount}) {
    final date = DateTime.now();
    final createDate = DateFormat('yyyyMMddHHmmss').format(date);
    
    final amountVND = (amount * 100).toInt(); 

    Map<String, String> params = {
      'vnp_Version': vnpVersion,
      'vnp_Command': vnpCommand,
      'vnp_TmnCode': vnpTmnCode,
      'vnp_Amount': amountVND.toString(),
      'vnp_CreateDate': createDate,
      'vnp_CurrCode': 'VND',
      'vnp_IpAddr': '127.0.0.1',
      'vnp_Locale': 'vn',
      'vnp_OrderInfo': 'Payment for $orderId',
      'vnp_OrderType': 'other',
      'vnp_ReturnUrl': vnpReturnUrl,
      'vnp_TxnRef': orderId,
    };

    var sortedParams = Map.fromEntries(
        params.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));

    final buffer = StringBuffer();
    sortedParams.forEach((key, value) {
      if (buffer.isNotEmpty) buffer.write('&');
      buffer.write('$key=$value');
    });

    final queryString = buffer.toString();

    var key = utf8.encode(vnpHashSecret);
    var bytes = utf8.encode(queryString);
    var hmacSha512 = Hmac(sha512, key);
    var digest = hmacSha512.convert(bytes);
    
    String finalUrl = '$vnpUrl?$queryString&vnp_SecureHash=$digest';
    
    return finalUrl;
  }
}