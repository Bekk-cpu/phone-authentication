import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OtpScreen extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onTap;
  OtpScreen({Key? key, required this.controller, required this.onTap})
      : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const maxSeconds = 59;
  int seconds = maxSeconds;
  Timer? timer;
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      } else {
        stopTimer();
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listenerOtp();
    startTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SmsAutoFill().unregisterListener();
  }

  void listenerOtp() async {
    await SmsAutoFill().listenForCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '00 : $seconds',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: PinFieldAutoFill(
                onCodeSubmitted: (code) {},
                decoration: UnderlineDecoration(
                    colorBuilder:
                    FixedColorBuilder(Colors.black.withOpacity(0.3)),
                    textStyle:
                    const TextStyle(fontSize: 20, color: Colors.black)),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: widget.onTap, child: const Text('verify')),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't receieve the code?"),
                InkWell(
                    onTap: () {},
                    child: const Text(
                      'RESEND',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}