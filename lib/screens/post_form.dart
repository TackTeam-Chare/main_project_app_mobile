import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_blog_app_project/constant.dart';
import 'package:test_blog_app_project/models/api_response.dart';
import 'package:test_blog_app_project/models/post.dart';
import 'package:test_blog_app_project/serveices/post_service.dart';
import 'package:test_blog_app_project/serveices/user_service.dart';
import 'login.dart';

class PostForm extends StatefulWidget {
  final Post? post;
  final String? title;

  PostForm({this.post, this.title});

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _txtControllerBody = TextEditingController();
  final TextEditingController _txtControllerTitle =
      TextEditingController(); // Add title field
  final TextEditingController _txtControllerCategory =
      TextEditingController(); // Add category field
  bool _loading = false;
  File? _imageFile;
  final _picker = ImagePicker();
  String? _imageBase64; // เพิ่มตัวแปรนี้

  Future getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      final String? imageBase64 = await getStringImage(imageFile);

      setState(() {
        _imageFile = imageFile;
        _imageBase64 = imageBase64;
      });
    }
  }

  void _createPost() async {
    String? image = _imageFile == null ? null : getStringImage(_imageFile);
    ApiResponse response = await createPost(
      _txtControllerTitle.text, // Send title
      _txtControllerCategory.text, // Send category
      _txtControllerBody.text,
      image,
    );

    if (response.error == null) {
      Navigator.of(context).pop();
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
      setState(() {
        _loading = !_loading;
      });
    }
  }

  void _editPost(int postId) async {
    ApiResponse response = await editPost(
      postId,
      _txtControllerTitle.text, // Send title
      _txtControllerCategory.text, // Send category
      _txtControllerBody.text,
    );
    if (response.error == null) {
      Navigator.of(context).pop();
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
      setState(() {
        _loading = !_loading;
      });
    }
  }

  @override
  void initState() {
    if (widget.post != null) {
      _txtControllerBody.text = widget.post!.body ?? '';
      _txtControllerTitle.text =
          widget.post!.title ?? ''; // Set title if available
      _txtControllerCategory.text =
          widget.post!.category ?? ''; // Set category if available
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}'),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                widget.post != null
                    ? SizedBox()
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        decoration: BoxDecoration(
                            image: _imageFile == null
                                ? null
                                : DecorationImage(
                                    image: FileImage(_imageFile ?? File('')),
                                    fit: BoxFit.cover)),
                        child: Center(
                          child: IconButton(
                            icon: Icon(Icons.image,
                                size: 50, color: Colors.black38),
                            onPressed: () {
                              getImage();
                            },
                          ),
                        ),
                      ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: TextFormField(
                          controller: _txtControllerTitle,
                          validator: (val) =>
                              val!.isEmpty ? 'Title is required' : null,
                          decoration: InputDecoration(
                            hintText: "Title...",
                            labelText: "Title",
                            labelStyle: TextStyle(
                              color: Colors.black, // สีของ Label
                              fontWeight: FontWeight.bold, // ตัวหนา
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 1,
                                color: Colors.black38,
                              ),
                            ),
                            prefixIcon: Icon(Icons.title),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: TextFormField(
                          controller: _txtControllerCategory,
                          validator: (val) =>
                              val!.isEmpty ? 'Category is required' : null,
                          decoration: InputDecoration(
                            hintText: "Category...",
                            labelText: "Category",
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 1,
                                color: Colors.black38,
                              ),
                            ),
                            prefixIcon: Icon(Icons.category),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: TextFormField(
                          controller: _txtControllerBody,
                          keyboardType: TextInputType.multiline,
                          maxLines: 9,
                          validator: (val) =>
                              val!.isEmpty ? 'Post body is required' : null,
                          decoration: InputDecoration(
                            hintText: "Post body...",
                            labelText: "Post Body",
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.black38),
                            ),
                            prefixIcon: Icon(Icons
                                .description), // ใส่ไอคอน "description" ที่ถูกต้อง
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _loading = !_loading;
                        });
                        if (widget.post == null) {
                          _createPost();
                        } else {
                          _editPost(widget.post!.id ?? 0);
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue, // สีพื้นหลังของปุ่ม
                      primary: Colors.white, // สีข้อความภายในปุ่ม
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.post_add), // ไอคอนสำหรับ "Post"
                        Text('Post'), // ข้อความ "Post"
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
