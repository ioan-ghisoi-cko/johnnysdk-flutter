import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';

import 'package:johnnysdk_flutter/main.dart';
import 'package:nock/nock.dart';

void main() {
  // setUpAll(() {
  //   nock.init();
  // });

  // setUp(() {
  //   nock.cleanAll();
  // });

  group('Card Tokenization', () {
    test('card details should be tokenized', () async {
      final request = CardTokenizationRequest(
          type: "card",
          number: "4242424242424242",
          expiryMonth: 6,
          expiryYear: 2028,
          billingAddress: BillingAddress(
            addressLine1: "Checkout.com",
            addressLine2: "90 Tottenham Court Road",
            city: "London",
            state: "London",
            zip: "W1T 4TJ",
            country: "GB",
          ),
          phone: Phone(
            number: "7432534231",
            countryCode: "+44",
          ));

      var res = await Checkout.tokenizeCard(
          "pk_test_4296fd52-efba-4a38-b6ce-cf0d93639d8a", request);

      expect(res.bin, "424242");
      expect(res.expiryYear, 2028);
      expect(res.billingAddress!.addressLine1, "Checkout.com");
      expect(res, isA<CardTokenizationResponse>());
    });

    test('should throw invalid data request', () async {
      try {
        final request = CardTokenizationRequest(
          type: "card",
          number: "42424242",
          expiryMonth: 6,
          expiryYear: 2028,
        );

        var res = await Checkout.tokenizeCard(
            "pk_test_4296fd52-efba-4a38-b6ce-cf0d93639d8a", request);
      } catch (e) {
        expect(e, isA<InvalidDataError>());
      }
    });

    test('should throw authentication error', () async {
      try {
        final request = CardTokenizationRequest(
          type: "card",
          number: "42424242",
          expiryMonth: 6,
          expiryYear: 2028,
        );

        var res = await Checkout.tokenizeCard("pk_test_", request);
      } catch (e) {
        expect(e, isA<UnauthorizedError>());
      }
    });

    test('should determine sb environment mbc', () async {
      var env = Checkout.getEnvironment(
          "pk_test_4296fd52-efba-4a38-b6ce-cf0d93639d8a");
      expect(env, "https://api.sandbox.checkout.com");
    });

    test('should determine live environment mbc', () async {
      var env =
          Checkout.getEnvironment("pk_4296fd52-efba-4a38-b6ce-cf0d93639d8a");
      expect(env, "https://api.checkout.com");
    });

    test('should determine sb environment nas', () async {
      var env = Checkout.getEnvironment("pk_sbox_xg66bnn6tpspd6pt3psc7otrqa=");
      expect(env, "https://api.sandbox.checkout.com");
    });

    test('should determine live environment nas', () async {
      var env = Checkout.getEnvironment("pk_xg66bnn6tpspd6pt3psc7otrqa=");
      expect(env, "https://api.checkout.com");
    });
  });
}
