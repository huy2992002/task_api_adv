import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:task_api_adv/components/button/td_elevated_button.dart';
import 'package:task_api_adv/components/snack_bar/td_snack_bar.dart';
import 'package:task_api_adv/components/snack_bar/top_snack_bar.dart';
import 'package:task_api_adv/components/text_field/td_text_field.dart';
import 'package:task_api_adv/components/text_field/td_text_field_password.dart';
import 'package:task_api_adv/constants/app_constant.dart';
import 'package:task_api_adv/gen/assets.gen.dart';
import 'package:task_api_adv/pages/auth/login_page.dart';
import 'package:task_api_adv/pages/auth/verification_code_page.dart';
import 'package:task_api_adv/resources/app_color.dart';
import 'package:task_api_adv/services/remote/auth_services.dart';
import 'package:task_api_adv/services/remote/body/register_body.dart';
import 'package:task_api_adv/utils/validator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  AuthServices authServices = AuthServices();
  final formKey = GlobalKey<FormState>();

  String? avatar;
  File? fileAvatar;

  bool isLoading = false;
  // bool isLoadingAvatar = false;

  Future<http.Response> postFile2(String url, File file) async {
    // String? token = SharedPrefs.token;
    final request = http.MultipartRequest('POST', Uri.parse(url));

    request.files.addAll([
      await http.MultipartFile.fromPath('file', file.path),
    ]);
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${null}',
    });

    final stream = await request.send();

    final response = http.Response.fromStream(stream).then((response) {
      if (response.statusCode == 200) {
        // print('response ${response.body}');
        return response;
      }
      throw Exception('Failed to load data');
    });

    return response;
  }

  Future<String?> uploadFile(File file) async {
    const url = AppConstant.endPointUploadFile;
    http.Response response = await postFile2(url, file);
    Map<String, dynamic> result = jsonDecode(response.body);
    // print('object $result');

    return result['body']['file'];
  }

  Future<String?> uploadAvatar() async {
    if (fileAvatar == null) return null;
    String? value;
    await uploadFile(fileAvatar!).then((response) {
      value = response;
    }).catchError((onError) {
      print('$onError');
      return null;
    });
    return value;
  }

  Future<void> pickAvatar() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result == null) return;
    fileAvatar = File(result.files.single.path!);
    // setState(() => isLoadingAvatar = true);
    // avatar = await uploadAvatar();
    // await Future.delayed(const Duration(milliseconds: 2600));
    // setState(() => isLoadingAvatar = false);
    setState(() {});
    print('object ${avatar!}');
  }

  Future<void> _sendOtp() async {
    if (formKey.currentState!.validate() == false) {
      return;
    }

    RegisterBody body = RegisterBody()
      ..name = nameController.text.trim()
      ..email = emailController.text.trim()
      ..password = passwordController.text
      ..avatar = fileAvatar != null ? await uploadAvatar() : null;

    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 2000));
    authServices.sendOtp(emailController.text.trim()).then((_) {
      showTopSnackBar(
        context,
        const TDSnackBar.success(message: 'Otp has been sent, check email 😍'),
      );
      setState(() => isLoading = false);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VerificationCodePage(
            registerBody: body,
          ),
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
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0).copyWith(
                top: MediaQuery.of(context).padding.top + 38.0, bottom: 16.0),
            children: [
              const Center(
                child: Text(
                  'Register',
                  style: TextStyle(color: AppColor.red, fontSize: 26.0),
                ),
              ),
              const SizedBox(height: 30.0),
              Center(
                child: _buildAvatar(),
              ),
              const SizedBox(height: 40.0),
              TdTextField(
                controller: nameController,
                hintText: 'Full Name',
                prefixIcon: const Icon(Icons.person, color: AppColor.orange),
                textInputAction: TextInputAction.next,
                validator: Validator.requiredValidator,
              ),
              const SizedBox(height: 20.0),
              TdTextField(
                controller: emailController,
                hintText: 'Email',
                prefixIcon: const Icon(Icons.email, color: AppColor.orange),
                textInputAction: TextInputAction.next,
                validator: Validator.emailValidator,
              ),
              const SizedBox(height: 20.0),
              TdTextFieldPassword(
                controller: passwordController,
                hintText: 'Password',
                textInputAction: TextInputAction.next,
                validator: Validator.passwordValidator,
              ),
              const SizedBox(height: 20.0),
              TdTextFieldPassword(
                controller: confirmPasswordController,
                onChanged: (_) => setState(() {}),
                hintText: 'Confirm Password',
                onFieldSubmitted: (_) => _sendOtp(),
                textInputAction: TextInputAction.done,
                validator:
                    Validator.confirmPasswordValidator(passwordController.text),
              ),
              const SizedBox(height: 56.0),
              TdElevatedButton(
                onPressed: _sendOtp,
                text: 'Sign up',
                isDisable: isLoading,
              ),
              const SizedBox(height: 12.0),
              RichText(
                text: TextSpan(
                  text: 'Do you have an account? ',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: AppColor.grey,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Sign in',
                      style: TextStyle(color: AppColor.red.withOpacity(0.86)),
                      recognizer: TapGestureRecognizer()
                        ..onTap =
                            () => Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                  (Route<dynamic> route) => false,
                                ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector _buildAvatar() {
    return GestureDetector(
      onTap: isLoading ? null : pickAvatar,
      child: Stack(
        children: [
          isLoading
              ? CircleAvatar(
                  radius: 34.6,
                  backgroundColor: Colors.orange.shade200,
                  child: const SizedBox.square(
                    dimension: 36.0,
                    child: CircularProgressIndicator(
                      color: AppColor.pink,
                      strokeWidth: 2.6,
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.all(3.6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColor.orange),
                  ),
                  child: CircleAvatar(
                    radius: 34.6,
                    backgroundImage: fileAvatar == null
                        // ? Assets.images.defaultAvatar.provider()
                        ? AssetImage(Assets.images.defaultAvatar.path)
                            as ImageProvider
                        : FileImage(
                            File(fileAvatar?.path ?? ''),
                          ),
                  ),
                ),
          const Positioned(
            right: 0.0,
            bottom: 0.0,
            child: Icon(Icons.favorite, size: 26.0, color: AppColor.green),
            // child: Container(
            //   padding: const EdgeInsets.all(4.0),
            //   decoration: BoxDecoration(
            //       color: Colors.white,
            //       shape: BoxShape.circle,
            //       border: Border.all(color: Colors.pink)),
            //   child: const Icon(
            //     Icons.camera_alt_outlined,
            //     size: 14.6,
            //     color: AppColor.pink,
            //   ),
            // ),
          ),
        ],
      ),
    );
  }
}
