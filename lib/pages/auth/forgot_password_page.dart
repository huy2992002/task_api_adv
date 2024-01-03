import 'package:flutter/material.dart';
import 'package:task_api_adv/components/button/td_elevated_button.dart';
import 'package:task_api_adv/components/snack_bar/td_snack_bar.dart';
import 'package:task_api_adv/components/snack_bar/top_snack_bar.dart';
import 'package:task_api_adv/components/text_field/td_text_field.dart';
import 'package:task_api_adv/gen/assets.gen.dart';
import 'package:task_api_adv/pages/auth/create_new_password_page.dart';
import 'package:task_api_adv/resources/app_color.dart';
import 'package:task_api_adv/services/remote/auth_services.dart';
import 'package:task_api_adv/utils/validator.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final authServices = AuthServices();
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool isLoading = false;

  Future<void> _sendOtp() async {
    if (formKey.currentState!.validate() == false) {
      return;
    }

    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    authServices.sendOtp(emailController.text.trim()).then((_) {
      showTopSnackBar(
        context,
        const TDSnackBar.success(message: 'Otp has been sent, check email 😍'),
      );
      setState(() => isLoading = false);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              CreateNewPasswordPage(email: emailController.text.trim()),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0)
              .copyWith(top: MediaQuery.of(context).padding.top + 38.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const Text('Forgot Password',
                    style: TextStyle(color: AppColor.red, fontSize: 24.0)),
                const SizedBox(height: 2.0),
                Text('Enter Your Email',
                    style: TextStyle(
                        color: AppColor.brown.withOpacity(0.8),
                        fontSize: 18.6)),
                const SizedBox(height: 38.0),
                Image.asset(
                  Assets.images.todoIcon.path,
                  width: 90.0,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 36.0),
                TdTextField(
                  controller: emailController,
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email, color: AppColor.orange),
                  validator: Validator.emailValidator,
                  onFieldSubmitted: (_) => _sendOtp(),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 68.0),
                TdElevatedButton.outline(
                  onPressed: _sendOtp,
                  text: 'Next',
                  isDisable: isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
