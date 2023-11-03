import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_blog_app_project/models/api_response.dart';
import 'package:test_blog_app_project/models/user.dart';
import 'package:test_blog_app_project/serveices/user_service.dart';

import '../constant.dart';
import 'home.dart';
import 'register.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool loading = false;

  void _loginUser() async {
    ApiResponse response = await login(txtEmail.text, txtPassword.text);
    if (response.error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        QuickAlert.show(
          // แสดง QuickAlert ทันทีเมื่อล็อคอินสำเร็จ
          context: context,
          type: QuickAlertType.success,
          title: 'Sign In Successful',
          text: 'Welcome, Customers.',
        );
      });
      _saveAndRedirectToHome(response.data as User);
    } else {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        QuickAlert.show(
          // แสดง QuickAlert ทันทีเมื่อล็อคอินสำเร็จ
          context: context,
          type: QuickAlertType.error,
          title: 'Sign In failed',
          text: 'Please Sign In again.',
        );
      });
    }
  }

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
        title: Text(
          'Login',
          style: TextStyle(fontSize: 30),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: formkey,
        child: ListView(
          padding: EdgeInsets.all(50),
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
              keyboardType: TextInputType.emailAddress,
              controller: txtEmail,
              validator: (val) => val!.isEmpty ? 'Invalid email address' : null,
              decoration: kInputDecoration('Email').copyWith(
                prefixIcon: Icon(Icons.email), // ไอคอนอีเมล
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: txtPassword,
              obscureText: true,
              validator: (val) =>
                  val!.length < 6 ? 'Required at least 6 chars' : null,
              decoration: kInputDecoration('Password').copyWith(
                prefixIcon: Icon(Icons.lock), // ไอคอนรหัสผ่าน
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (formkey.currentState!.validate()) {
                  setState(() {
                    loading = true;
                    _loginUser();
                  });
                }
              },
              icon: loading
                  ? CircularProgressIndicator() // ไอคอนแสดงสถานะการโหลด
                  : Icon(Icons.login), // ไอคอนปกติ (ตัวอย่างเช่น login)
              label: Text('Login'),
            ),
            SizedBox(
              height: 10,
            ),
            kLoginRegisterHint('Dont have an acount? ', 'Register', () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Register()),
                  (route) => false);
            })
          ],
        ),
      ),
    );
  }
}
