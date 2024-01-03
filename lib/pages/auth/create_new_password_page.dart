import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:task_api_adv/components/button/td_elevated_button.dart';
import 'package:task_api_adv/components/snack_bar/td_snack_bar.dart';
import 'package:task_api_adv/components/snack_bar/top_snack_bar.dart';
import 'package:task_api_adv/components/text_field/td_text_field_password.dart';
import 'package:task_api_adv/gen/assets.gen.dart';
import 'package:task_api_adv/pages/auth/login_page.dart';
import 'package:task_api_adv/resources/app_color.dart';
import 'package:task_api_adv/services/remote/auth_services.dart';
import 'package:task_api_adv/services/remote/body/new_password_body.dart';
import 'package:task_api_adv/services/remote/code_error.dart';
import 'package:task_api_adv/utils/validator.dart';

class CreateNewPasswordPage extends StatefulWidget {
  const CreateNewPasswordPage({super.key, required this.email});

  final String email;

  @override
  State<CreateNewPasswordPage> createState() => _CreateNewPasswordPageState();
}

class _CreateNewPasswordPageState extends State<CreateNewPasswordPage> {
  final verificationCodeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final focusNode = FocusNode();
  final authServices = AuthServices();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> _sendOtp() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    authServices.sendOtp(widget.email).then((_) {
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
      verificationCodeController.clear();
      setState(() => isLoading = false);
    });
  }

  Future<void> _newPassword() async {
    if (formKey.currentState!.validate() == false) {
      return;
    }

    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    final body = NewPasswordBody()
      ..email = widget.email
      ..password = passwordController.text
      ..code = verificationCodeController.text;

    authServices.postForgotPassword(body).then((response) {
      final data = jsonDecode(response.body);
      if (data['status_code'] == 200) {
        showTopSnackBar(
          context,
          const TDSnackBar.success(message: 'New password is created 😍'),
        );
        // setState(() => isLoading = false);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LoginPage(email: widget.email),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        print('object message ${data['message']}');
        showTopSnackBar(
          context,
          TDSnackBar.error(
              message: (data['message'] as String?)?.toLang ?? '😐'),
        );
        verificationCodeController.clear();
        setState(() => isLoading = false);
      }
    }).catchError((onError) {
      print('object $onError');
      showTopSnackBar(
        context,
        const TDSnackBar.error(message: "Server error 😐"),
      );
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0)
                .copyWith(top: MediaQuery.of(context).padding.top + 38.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const Text('Forgot Password',
                      style: TextStyle(color: AppColor.red, fontSize: 24.0)),
                  const SizedBox(height: 2.0),
                  Text('Create New Password',
                      style: TextStyle(
                          color: AppColor.brown.withOpacity(0.8),
                          fontSize: 18.6)),
                  const SizedBox(height: 38.0),
                  Image.asset(
                    Assets.images.todoIcon.path,
                    width: 90.0,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 46.0),
                  PinCodeTextField(
                    controller: verificationCodeController,
                    focusNode: focusNode,
                    textInputAction: TextInputAction.next,
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
                  ),
                  const SizedBox(height: 6.0),
                  RichText(
                    text: TextSpan(
                      text: 'You didn\'t receive the pin code? ',
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: AppColor.grey,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Resend',
                          style:
                              TextStyle(color: AppColor.red.withOpacity(0.86)),
                          recognizer: TapGestureRecognizer()
                            ..onTap = isLoading
                                ? null
                                : () {
                                    verificationCodeController.clear();
                                    focusNode.unfocus();
                                    _sendOtp();
                                  },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  TdTextFieldPassword(
                    controller: passwordController,
                    textInputAction: TextInputAction.next,
                    hintText: 'Password',
                    validator: Validator.passwordValidator,
                  ),
                  const SizedBox(height: 18.0),
                  TdTextFieldPassword(
                    controller: confirmPasswordController,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.done,
                    hintText: 'Confirm Password',
                    validator: Validator.confirmPasswordValidator(
                        passwordController.text),
                  ),
                  const SizedBox(height: 72.0),
                  TdElevatedButton.outline(
                    onPressed: _newPassword,
                    text: 'Done',
                    isDisable: isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
