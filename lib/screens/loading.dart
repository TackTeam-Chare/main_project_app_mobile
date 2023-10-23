
import 'package:flutter/material.dart';
import 'package:test_blog_app_project/constant.dart';
import 'package:test_blog_app_project/models/api_response.dart';
import 'package:test_blog_app_project/screens/home.dart';
import 'package:test_blog_app_project/serveices/user_service.dart';

import 'login.dart';


class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  void _loadUserInfo() async {
    String token = await getToken();
    if(token == ''){
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Login()), (route) => false);
    }
    else {
      ApiResponse response = await getUserDetail();
      if (response.error == null){
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Home()), (route) => false);
      }
      else if (response.error == unauthorized){
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Login()), (route) => false);
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${response.error}'),
        ));
      }
    }
  }

  @override
  void initState() {
    _loadUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Center(
        child: CircularProgressIndicator()
      ),
    );
  }
}