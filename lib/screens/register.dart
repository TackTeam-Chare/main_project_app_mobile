import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_blog_app_project/models/api_response.dart';
import 'package:test_blog_app_project/models/user.dart';
import 'package:test_blog_app_project/screens/home.dart';
import 'package:test_blog_app_project/serveices/user_service.dart';

import '../constant.dart';
import 'login.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool loading = false;
  TextEditingController nameController = TextEditingController(),
      emailController = TextEditingController(),
      passwordController = TextEditingController(),
      passwordConfirmController = TextEditingController();

  void _registerUser() async {
    ApiResponse response = await register(
        nameController.text, emailController.text, passwordController.text);
    if (response.error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        QuickAlert.show(
          // แสดง QuickAlert ทันทีเมื่อล็อคอินสำเร็จ
          context: context,
          type: QuickAlertType.success,
          title: 'Login successful',
          text: 'Welcome users',
        );
      });
      _saveAndRedirectToHome(response.data as User);
    } else {
      setState(() {
        loading = !loading;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        QuickAlert.show(
          // แสดง QuickAlert ทันทีเมื่อล็อคอินสำเร็จ
          context: context,
          type: QuickAlertType.error,
          title: 'Login failed',
          text: 'Please log in again.',
        );
      });
    }
  }

  // Save and redirect to home
  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Home()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        centerTitle: true,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          children: [
            Center(
              child: ClipOval(
                child: Container(
                  width: 135, // กำหนดความกว้างตามที่คุณต้องการ
                  height: 137, // กำหนดความสูงตามที่คุณต้องการ
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // กำหนดรูปร่างเป็นวงกลม
                    color: Colors.white, // สีพื้นหลัง
                    border:
                        Border.all(color: Colors.grey, width: 2.0), // เส้นขอบ
                  ),
                  child: Image.asset(
                    'assets/images/person.png',
                    fit: BoxFit.cover, // ปรับขนาดรูปให้พอดีกับ Container
                  ),
                ),
              ),
            ),
            SizedBox(height: 50),
            TextFormField(
              controller: nameController,
              validator: (val) => val!.isEmpty ? 'Invalid name' : null,
              decoration: kInputDecoration('Name').copyWith(
                prefixIcon: Icon(Icons.person), // ไอคอนชื่อ
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (val) => val!.isEmpty ? 'Invalid email address' : null,
              decoration: kInputDecoration('Email').copyWith(
                prefixIcon: Icon(Icons.email), // ไอคอนอีเมล
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
                controller: passwordController,
                obscureText: true,
                validator: (val) =>
                    val!.length < 6 ? 'Required at least 6 chars' : null,
                decoration: kInputDecoration('Password').copyWith(
                  prefixIcon: Icon(Icons.lock),
                )),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: passwordConfirmController,
              obscureText: true,
              validator: (val) => val != passwordController.text
                  ? 'Confirm password does not match'
                  : null,
              decoration: kInputDecoration('Confirm password').copyWith(
                prefixIcon: Icon(Icons.lock), // ไอคอนรหัสผ่าน
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    loading = !loading;
                    _registerUser();
                  });
                }
              },
              icon: loading
                  ? CircularProgressIndicator() // ไอคอนแสดงสถานะการโหลด
                  : Icon(
                      Icons.person_add), // ไอคอนปกติ (ตัวอย่างเช่น check mark)
              label: Text('Register'),
            ),
            SizedBox(
              height: 20,
            ),
            kLoginRegisterHint('Already have an account? ', 'Login', () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Login()),
                  (route) => false);
            })
          ],
        ),
      ),
    );
  }
}
