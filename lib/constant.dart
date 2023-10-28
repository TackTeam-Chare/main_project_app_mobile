// ----- STRINGS ------
import 'package:flutter/material.dart';

const baseURL = 'http://192.168.1.150:8000/api/';
const loginURL = 'http://192.168.1.150:8000/api/login';
const registerURL = 'http://192.168.1.150:8000/api/register';
const logoutURL = 'http://192.168.1.150:8000/api/logout';
const userURL = 'http://192.168.1.150:8000/api/user';
const postsURL = 'http://192.168.1.150:8000/api/posts';
const commentsURL = 'http://192.168.1.150:8000/api/comments';

// ----- Errors -----
const serverError = 'Server error';
const unauthorized = 'Unauthorized';
const somethingWentWrong = 'Something went wrong, try again!';

// --- input decoration
InputDecoration kInputDecoration(String label) {
  return InputDecoration(
      labelText: label,
      contentPadding: EdgeInsets.all(10),
      border: OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: Colors.black)));
}

// button

TextButton kTextButton(String label, Function onPressed) {
  return TextButton(
    child: Text(
      label,
      style: TextStyle(color: Colors.white),
    ),
    style: ButtonStyle(
        backgroundColor:
            MaterialStateColor.resolveWith((states) => Colors.blue),
        padding: MaterialStateProperty.resolveWith(
            (states) => EdgeInsets.symmetric(vertical: 10))),
    onPressed: () => onPressed(),
  );
}

// loginRegisterHint
Row kLoginRegisterHint(String text, String label, Function onTap) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(text),
      GestureDetector(
          child: Text(label, style: TextStyle(color: Colors.blue)),
          onTap: () => onTap())
    ],
  );
}

// likes and comment btn

Expanded kLikeAndComment(
    int value, IconData icon, Color color, Function onTap) {
  return Expanded(
    child: Material(
      child: InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              SizedBox(width: 4),
              Text('$value')
            ],
          ),
        ),
      ),
    ),
  );
}

Expanded kShareButton(Function onTap) {
  return Expanded(
    child: Material(
      child: InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.share,
                size: 16,
                color: Colors.black54,
              ),
              SizedBox(width: 4),
              Text('Share')
            ],
          ),
        ),
      ),
    ),
  );
}
// InkWell kShareButton(Function onTap) {
//   return InkWell(
//     onTap: () => onTap(),
//     child: Container(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.blue, // สีพื้นหลังของปุ่ม
//         borderRadius: BorderRadius.circular(25), // กำหนดขอบมน
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.share,
//             size: 16,
//             color: Colors.white, // สีไอคอน
//           ),
//           SizedBox(width: 4),
//           Text(
//             'Share',
//             style: TextStyle(
//               color: Colors.white, // สีข้อความ
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
