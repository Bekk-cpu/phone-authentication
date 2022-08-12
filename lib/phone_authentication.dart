// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:phone_auth/HomePage.dart';
import 'package:phone_auth/widgets/showsnackbar.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'otpVerification.dart';

class PhoneAuth extends StatefulWidget {
  const PhoneAuth({Key? key}) : super(key: key);

  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  String initialCountry = 'US';
  PhoneNumber phonenumber = PhoneNumber(isoCode: 'US');
  void getPhoneNumber(PhoneNumber phoneNumber) async {
    PhoneNumber number = await PhoneNumber.getRegionInfoFromPhoneNumber(
        phoneNumber.phoneNumber!, phoneNumber.isoCode!);
    setState(() {
      phonenumber = number;
    });
    phoneSignIn(number.phoneNumber!);
  }

  Future phoneSignIn(String phoneNumber) async {
    TextEditingController codeController = TextEditingController();
    if (kIsWeb) {
      ConfirmationResult result =
          await _auth.signInWithPhoneNumber(phoneNumber);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => OtpScreen(
              controller: codeController,
              onTap: () async {
                PhoneAuthCredential credential = PhoneAuthProvider.credential(
                    verificationId: result.verificationId,
                    smsCode: codeController.text.trim());
                await _auth.signInWithCredential(credential);
                final signature = await SmsAutoFill().getAppSignature;
                showSnackBar(context, signature);
              })));
    } else {
      await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
            try {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: ((context) => const HomePage())),
                  (route) => false);
            } on FirebaseAuthException catch (e) {
              showSnackBar(context, e.message!);
            }
          },
          verificationFailed: (e) {
            showSnackBar(context, e.message!);
          },
          codeSent: ((String verificationId, int? resendToken) async {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => OtpScreen(
                    controller: codeController,
                    onTap: () async {
                      PhoneAuthCredential credential =
                          PhoneAuthProvider.credential(
                              verificationId: verificationId,
                              smsCode: codeController.text.trim());
                      await _auth.signInWithCredential(credential);
                    })));
          }),
          codeAutoRetrievalTimeout: (String verificationId) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: InternationalPhoneNumberInput(
                    initialValue: phonenumber,
                    onInputChanged: (PhoneNumber number) {
                      phonenumber = number;
                    },
                    onInputValidated: (bool value) {},
                    selectorConfig: const SelectorConfig(
                      selectorType: PhoneInputSelectorType.DIALOG,
                    ),
                    ignoreBlank: true,
                    autoValidateMode: AutovalidateMode.disabled,
                    selectorTextStyle: const TextStyle(color: Colors.black),
                    textFieldController: phoneNumberController,
                    formatInput: true,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: false),
                    inputBorder: const OutlineInputBorder(),
                    onSaved: (PhoneNumber number) {
                      showSnackBar(context, 'On Saved: $number');
                      setState(() {
                        phonenumber = number;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                    onPressed: () {
                      getPhoneNumber(phonenumber);
                    },
                    child: const Text('Verify'))
                //
              ],
            )));
  }
}
