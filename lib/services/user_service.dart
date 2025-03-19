import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';

class UserService {
  Future<UserModel?> getUserByUid(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        // Nếu đã có factory UserModel.fromMap, dùng luôn cho gọn
        return UserModel.fromMap(data);
      } else {
        print('Không tìm thấy user có uid: $uid');
        return null;
      }
    } catch (e) {
      print('Lỗi khi lấy thông tin user: $e');
      return null;
    }
  }
}
