import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:task_api_adv/components/snack_bar/td_snack_bar.dart';
import 'package:task_api_adv/components/snack_bar/top_snack_bar.dart';
import 'package:task_api_adv/gen/assets.gen.dart';
import 'package:task_api_adv/pages/auth/login_page.dart';
import 'package:task_api_adv/resources/app_color.dart';
import 'package:task_api_adv/services/remote/auth_services.dart';
import 'package:task_api_adv/services/remote/body/register_body.dart';

class VerificationCodePage extends StatefulWidget {
  const VerificationCodePage({super.key, required this.registerBody});

  final RegisterBody registerBody;

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  TextEditingController verificationCodeController = TextEditingController();
  FocusNode focusNode = FocusNode();
  AuthServices authServices = AuthServices();
  bool isLoading = false;

  @override
  initState() {
    super.initState();
    focusNode.requestFocus();
  }

  Future<void> _sendOtp() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    authServices.sendOtp(widget.registerBody.email ?? '').then((_) {
      showTopSnackBar(
        context,
        const TDSnackBar.success(message: 'Otp has been sent, check email 😍'),
      );
      setState(() => isLoading = false);
    }).catchError((onError) {
      String? error = onError.message;
      showTopSnackBar(
        context,
        TDSnackBar.error(
          message: error ?? 'Server error 😐',
        ),
      );
      setState(() => isLoading = false);
    });
  }

  Future<void> _register() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    authServices
        .register(widget.registerBody..code = verificationCodeController.text)
        .then((_) {
      showTopSnackBar(
        context,
        const TDSnackBar.success(message: 'Register successfully, login 😍'),
      );
      // setState(() => isLoading = false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginPage(email: widget.registerBody.email),
        ),
        (Route<dynamic> route) => false,
      );
    }).catchError((onError) {
      String? error = onError.message;
      showTopSnackBar(
        context,
        TDSnackBar.error(
          message: error ?? 'Server error 😐',
        ),
      );
      verificationCodeController.clear();
      focusNode.requestFocus();
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0).copyWith(
              top: MediaQuery.of(context).padding.top + 38.0, bottom: 16.0),
          child: Column(
            children: [
              const Text(
                'Enter Verification Code',
                style: TextStyle(color: Colors.red, fontSize: 24.0),
              ),
              const SizedBox(height: 38.0),
              Image.asset(Assets.images.todoIcon.path,
                  width: 90.0, fit: BoxFit.cover),
              const SizedBox(height: 46.0),
              PinCodeTextField(
                  controller: verificationCodeController,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  appContext: context,
                  textStyle: const TextStyle(color: Colors.red),
                  length: 4,
                  cursorColor: Colors.orange,
                  cursorHeight: 16.0,
                  cursorWidth: 2.0,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8.6),
                    fieldHeight: 46.0,
                    fieldWidth: 40.0,
                    activeFillColor: Colors.red,
                    inactiveColor: Colors.orange,
                    activeColor: Colors.red,
                    selectedColor: Colors.orange,
                  ),
                  scrollPadding: EdgeInsets.zero,
                  // onEditingComplete: () {
                  //   verificationCodeController.clear();
                  //   focusNode.unfocus();
                  // },
                  onCompleted: (_) => _register()),
              const SizedBox(height: 6.0),
              RichText(
                text: TextSpan(
                  text: 'You didn\'t receive the pin code? ',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Resend',
                      style: TextStyle(color: AppColor.red.withOpacity(0.86)),
                      recognizer: TapGestureRecognizer()
                        ..onTap = isLoading
                            ? null
                            : () {
                                verificationCodeController.clear();
                                focusNode.requestFocus();
                                _sendOtp();
                              },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 46.0),
              if (isLoading)
                const CircularProgressIndicator(
                    color: AppColor.primary, strokeWidth: 2.2),
            ],
          ),
        ),
      ),
    );
  }
}
