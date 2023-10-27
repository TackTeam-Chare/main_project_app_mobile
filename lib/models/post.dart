import 'user.dart';

class Post {
  int? id;
  String? title;
  String? category;
  String? body;
  String? image;
  int? likesCount;
  int? commentsCount;
  User? user;
  bool? selfLiked;
   List<String> categories;

  Post({
    this.id,
    this.title, // เพิ่ม title
    this.category, // เพิ่ม category
    this.body,
    this.image,
    this.likesCount,
    this.commentsCount,
    this.user,
    this.selfLiked,
    required this.categories,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        id: json['id'],
        title: json['title'], // เพิ่ม title
        category: json['category'], // เพิ่ม category
        body: json['body'],
        image: json['image'],
        likesCount: json['likes_count'],
        commentsCount: json['comments_count'],
        selfLiked: json['likes'].length > 0,
        user: User(
            id: json['user']['id'],
            name: json['user']['name'],
            image: json['user']['image']), categories: []);
  }
}
