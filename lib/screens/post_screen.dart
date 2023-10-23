import 'package:flutter/material.dart';
import 'package:test_blog_app_project/constant.dart';
import 'package:test_blog_app_project/models/api_response.dart';
import 'package:test_blog_app_project/models/post.dart';
import 'package:test_blog_app_project/screens/comment_screen.dart';
import 'package:test_blog_app_project/serveices/post_service.dart';
import 'package:test_blog_app_project/serveices/user_service.dart';

import 'login.dart';
import 'post_form.dart';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<dynamic> _postList = [];
  int userId = 0;
  bool _loading = true;

  // Get all posts
  Future<void> retrievePosts() async {
    userId = await getUserId();
    ApiResponse response = await getPosts();

    if (response.error == null) {
      setState(() {
        _postList = response.data as List<dynamic>;
        _loading = _loading ? !_loading : _loading;
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${response.error}'),
      ));
    }
  }

  void _handleDeletePost(int postId) async {
    ApiResponse response = await deletePost(postId);
    if (response.error == null) {
      retrievePosts();
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

  // Post like dislike
  void _handlePostLikeDislike(int postId) async {
    ApiResponse response = await likeUnlikePost(postId);

    if (response.error == null) {
      retrievePosts();
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

  @override
  void initState() {
    retrievePosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () {
              return retrievePosts();
            },
            child: ListView.builder(
                itemCount: _postList.length,
                itemBuilder: (BuildContext context, int index) {
                  Post post = _postList[index];
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: post.user!.image != null
                                        ? DecorationImage(
                                            image: NetworkImage(
                                                '${post.user!.image}'),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    color: Colors.amber,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'User : ${post.user!.name}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Title : ',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                        ),
                                        Text(
                                          '${post.title}', // แสดง Title (หัวข้อบท)
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 26,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Category : ',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${post.category}', // แสดงหมวดหมู่ของบทความ
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (post.user!.id == userId)
                              PopupMenuButton(
                                child: Icon(
                                  Icons.more_vert,
                                  color: Colors.black,
                                ),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: Text('Edit'),
                                    value: 'edit',
                                  ),
                                  PopupMenuItem(
                                    child: Text('Delete'),
                                    value: 'delete',
                                  )
                                ],
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => PostForm(
                                        title: 'Edit Post',
                                        post: post,
                                      ),
                                    ));
                                  } else {
                                    _handleDeletePost(post.id ?? 0);
                                  }
                                },
                              ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          '${post.body}',
                          style: TextStyle(fontSize: 16),
                        ),
                        if (post.image != null)
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 180,
                            margin: EdgeInsets.only(top: 12),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage('${post.image}'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            kLikeAndComment(
                              post.likesCount ?? 0,
                              post.selfLiked == true
                                  ? Icons.favorite
                                  : Icons.favorite_outline,
                              post.selfLiked == true
                                  ? Colors.red
                                  : Colors.black54,
                              () {
                                _handlePostLikeDislike(post.id ?? 0);
                              },
                            ),
                            Container(
                              height: 25,
                              width: 0.5,
                              color: Colors.black38,
                            ),
                            kLikeAndComment(
                              post.commentsCount ?? 0,
                              Icons.sms_outlined,
                              Colors.black54,
                              () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => CommentScreen(
                                    postId: post.id,
                                  ),
                                ));
                              },
                            ),
                          ],
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 0.5,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  );
                }),
          );
  }
}
