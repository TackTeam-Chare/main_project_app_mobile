import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:test_blog_app_project/models/api_response.dart';
import 'package:test_blog_app_project/models/user.dart';
import 'package:test_blog_app_project/serveices/user_service.dart';

import '../constant.dart';
import 'login.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user;
  bool loading = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String newEmail = '';
  String newPassword = '';

  // final _picker = ImagePicker();
  TextEditingController txtNameController = TextEditingController();
  TextEditingController txtEmailController = TextEditingController();
  TextEditingController txtPasswordController = TextEditingController();

  // Future getImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _imageFile = File(pickedFile.path);
  //     });
  //   }
  // }

  // get user detail
  void getUser() async {
    ApiResponse response = await getUserDetail();
    if (response.error == null) {
      setState(() {
        user = response.data as User;
        loading = false;
        txtNameController.text = user!.name ?? '';
        txtEmailController.text = user!.email ?? '';
        txtPasswordController.text = user!.password ?? '';
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  // update profile
  void updateProfile() async {
    ApiResponse response = await updateUser(
      txtNameController.text,
      txtEmailController.text,
      txtPasswordController.text,
      txtPasswordController.text,
    );
    setState(() {
      loading = false;
    });
    if (response.error == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.data}')));
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  void _showDeleteAccountDialog() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete your account?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      _deleteAccount();
    }
  }

  void _deleteAccount() async {
    ApiResponse response = await deleteAccount();
    if (response.error == null) {
      // ลบบัญชีผู้ใช้สำเร็จ และเปลี่ยนไปหน้าล็อกอิน
      WidgetsBinding.instance.addPostFrameCallback((_) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Account deleted successfully',
        );
      });
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Login()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  void _showChangeEmailDialog() async {
    String newEmail = ''; // ต้องกำหนดค่าเริ่มต้นให้กับ newEmail

    bool confirmChangeEmail = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เปลี่ยนอีเมล์'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: kInputDecoration('อีเมล์ใหม่'),
                  controller: txtEmailController,
                  validator: (val) => val!.isEmpty ? 'Invalid Email' : null,
                  onChanged: (value) {
                    newEmail = value;
                  },
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('เปลี่ยน'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmChangeEmail == true) {
      _changeEmail(newEmail);
    }
  }

  void _changeEmail(String newEmail) async {
    if (newEmail != null) {
      setState(() {
        loading = true;
      });

      ApiResponse response = await changeEmail(newEmail);

      if (response.error == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${response.data}')));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          QuickAlert.show(
            // แสดง QuickAlert ทันทีเมื่อล็อคอินสำเร็จ
            context: context,
            type: QuickAlertType.success,
            title: 'Data Editing Completed.',
          );
        });
      } else if (response.error == unauthorized) {
        logout().then((value) => {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Login()),
                  (route) => false)
            });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${response.error}')));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          QuickAlert.show(
            // แสดง QuickAlert ทันทีเมื่อล็อคอินสำเร็จ
            context: context,
            type: QuickAlertType.error,
            title: 'Failed to edit data!',
            text: 'Please try editing again.',
          );
        });
      }

      setState(() {
        loading = false;
      });
    }
  }

  void _showChangePasswordDialog() async {
    String newPassword = ''; // ต้องกำหนดค่าเริ่มต้นให้กับ newEmail

    bool confirmChangPassword = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เปลี่ยนรหัสผ่าน'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: kInputDecoration('รหัสผ่าน'),
                  controller: txtPasswordController,
                  validator: (val) => val!.isEmpty ? 'Invalid Email' : null,
                  onChanged: (value) {
                    newPassword = value;
                  },
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('เปลี่ยน'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmChangPassword == true) {
      _changePassword(newPassword);
    }
  }

  void _changePassword(String newPassword) async {
    if (newPassword != null) {
      setState(() {
        loading = true;
      });
      ApiResponse response = await changePassword(newPassword);

      if (response.error == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${response.data}')));
      } else if (response.error == unauthorized) {
        logout().then((value) => {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Login()),
                  (route) => false)
            });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${response.error}')));
      }

      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(
            // child: CircularProgressIndicator(),
            )
        : Padding(
            padding: EdgeInsets.only(top: 5, left: 40, right: 40),
            child: ListView(
              children: [
                Center(
                  child: GestureDetector(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Image.network(
                        'https://cdn-icons-png.flaticon.com/512/3048/3048173.png', // URL ของรูปภาพจากอินเทอร์เน็ต
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Form(
                  key: formKey,
                  child: TextFormField(
                    decoration: kInputDecoration('Name').copyWith(
                      prefixIcon: Icon(Icons.person_2),
                    ),
                    controller: txtNameController,
                    validator: (val) => val!.isEmpty ? 'Invalid Name' : null,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: kInputDecoration('Email').copyWith(
                    prefixIcon: Icon(Icons.email),
                  ),
                  controller: txtEmailController,
                  validator: (val) => val!.isEmpty ? 'Invalid Email' : null,
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: kInputDecoration('Password').copyWith(
                    prefixIcon: Icon(Icons.lock),
                  ),
                  controller: txtPasswordController,
                  validator: (val) => val!.isEmpty ? 'Invalid Password' : null,
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    _showChangePasswordDialog();
                  },
                  child: Text(
                    'รีเซ็ตรหัสผ่าน',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    _showChangeEmailDialog();
                  },
                  child: Text(
                    'เปลี่ยนอีเมล์',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green, // เปลี่ยนสีปุ่มเป็นสีเขียว
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                kTextButton('Update', () {
                  if (formKey.currentState!.validate()) {
                    setState(() {
                      loading = true;
                    });
                    updateProfile();
                  }
                }),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    _showDeleteAccountDialog();
                  },
                  child: Text(
                    'Delete Account',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // เปลี่ยนสีปุ่มเป็นสีแดง
                  ),
                ),
              ],
            ),
          );
  }
}
