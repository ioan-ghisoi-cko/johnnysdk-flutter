import 'dart:convert';

import 'package:johnnysdk_flutter/src/utils/frames_typedef.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class CardTokenizationResponse {
  String? type;
  String? token;
  String? expiresOn;
  int? expiryMonth;
  int? expiryYear;
  String? scheme;
  String? last4;
  String? bin;
  String? cardType;
  String? cardCategory;
  String? issuer;
  String? issuerCountry;
  String? productId;
  String? productType;
  BillingAddress? billingAddress;
  Phone? phone;
  String? name;

  CardTokenizationResponse({
    this.type,
    this.token,
    this.expiresOn,
    this.expiryMonth,
    this.expiryYear,
    this.scheme,
    this.last4,
    this.bin,
    this.cardType,
    this.cardCategory,
    this.issuer,
    this.issuerCountry,
    this.productId,
    this.productType,
    this.billingAddress,
    this.phone,
    this.name,
  });

  CardTokenizationResponse.fromJson(Map<String, dynamic> json) {
    type = json['type'] as String?;
    token = json['token'] as String?;
    expiresOn = json['expires_on'] as String?;
    expiryMonth = json['expiry_month'] as int?;
    expiryYear = json['expiry_year'] as int?;
    scheme = json['scheme'] as String?;
    last4 = json['last4'] as String?;
    bin = json['bin'] as String?;
    cardType = json['card_type'] as String?;
    cardCategory = json['card_category'] as String?;
    issuer = json['issuer'] as String?;
    issuerCountry = json['issuer_country'] as String?;
    productId = json['product_id'] as String?;
    productType = json['product_type'] as String?;
    billingAddress = (json['billing_address'] as Map<String, dynamic>?) != null
        ? BillingAddress.fromJson(
            json['billing_address'] as Map<String, dynamic>)
        : null;
    phone = (json['phone'] as Map<String, dynamic>?) != null
        ? Phone.fromJson(json['phone'] as Map<String, dynamic>)
        : null;
    name = json['name'] as String?;
  }
}

class BillingAddress {
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? state;
  String? zip;
  String? country;

  BillingAddress({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.zip,
    this.country,
  });

  BillingAddress.fromJson(Map<String, dynamic> json) {
    addressLine1 = json['address_line1'] as String?;
    addressLine2 = json['address_line2'] as String?;
    city = json['city'] as String?;
    state = json['state'] as String?;
    zip = json['zip'] as String?;
    country = json['country'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['address_line1'] = addressLine1;
    json['address_line2'] = addressLine2;
    json['city'] = city;
    json['state'] = state;
    json['zip'] = zip;
    json['country'] = country;
    return json;
  }
}

class Phone {
  String? number;
  String? countryCode;

  Phone({
    this.number,
    this.countryCode,
  });

  Phone.fromJson(Map<String, dynamic> json) {
    number = json['number'] as String?;
    countryCode = json['country_code'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['number'] = number;
    json['country_code'] = countryCode;
    return json;
  }
}

class CardTokenizationRequest {
  String? type;
  late String number;
  late int expiryMonth;
  late int expiryYear;
  String? cvv;
  String? name;
  BillingAddress? billingAddress;
  Phone? phone;

  CardTokenizationRequest({
    this.type,
    required this.number,
    required this.expiryMonth,
    required this.expiryYear,
    this.cvv,
    this.name,
    this.billingAddress,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['type'] = type;
    json['number'] = number;
    json['expiry_month'] = expiryMonth;
    json['expiry_year'] = expiryYear;
    json['cvv'] = cvv;
    json['name'] = name;
    json['billing_address'] = billingAddress?.toJson();
    json['phone'] = phone?.toJson();
    return json;
  }
}

class Checkout {
  static final SANDBOX_BASE_URL = "https://api.sandbox.checkout.com";
  static final LIVE_BASE_URL = "https://api.checkout.com";
  static final MBC_LIVE_PUBLIC_KEY_REGEX =
      RegExp(r"^pk_?(\w{8})-(\w{4})-(\w{4})-(\w{4})-(\w{12})$");
  static final NAS_LIVE_PUBLIC_KEY_REGEX =
      new RegExp(r"^pk_?[a-z2-7]{26}[a-z2-7*#$=]$");

  static String getEnvironment(String key) {
    if (MBC_LIVE_PUBLIC_KEY_REGEX.hasMatch(key) ||
        NAS_LIVE_PUBLIC_KEY_REGEX.hasMatch(key)) {
      return LIVE_BASE_URL;
    } else {
      return SANDBOX_BASE_URL;
    }
  }

  Checkout();
  static Future<CardTokenizationResponse> tokenizeCard(
      String key, CardTokenizationRequest request) async {
    CardTokenizationRequest data = request;
    //encode Map to JSON
    var body = json.encode(data);
    var url = Uri.parse(getEnvironment(key) + '/tokens');

    var response = await http.post(url,
        headers: {"Content-Type": "application/json", "Authorization": key},
        body: body);

    if (response.statusCode == 401) throw new UnauthorizedError();

    if (response.statusCode == 422)
      throw new InvalidDataError.fromJson(jsonDecode(response.body));

    if ((response.statusCode ~/ 100) == 2) {
      print("${response.statusCode}");
      print("${response.body}");
      return CardTokenizationResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response);
    }
  }
}

class UnauthorizedError implements Exception {
  UnauthorizedError();
}

class InvalidDataError {
  String requestId;
  String errorType;
  List<String> errorCodes;

  InvalidDataError({
    required this.requestId,
    required this.errorType,
    required this.errorCodes,
  });

  factory InvalidDataError.fromJson(Map<String, dynamic> json) =>
      InvalidDataError(
        requestId: json["request_id"],
        errorType: json["error_type"],
        errorCodes: List<String>.from(json["error_codes"].map((x) => x)),
      );
}
