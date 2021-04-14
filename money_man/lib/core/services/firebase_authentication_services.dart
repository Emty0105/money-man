import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  // lấy thông tin từ stream để listen tới sự thay đổi của authentication
  Stream<User> get userStream {
    // listen để in ra terminal
    _auth.authStateChanges().listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
    // trả về stream
    return _auth.authStateChanges();
  }

  // lấy user hiện tại
  User get currentUser => _auth.currentUser;

  // đăng nhập ẩn danh
  Future signInAnonymously() async {
    try {
      final res = await _auth.signInAnonymously();
      return res.user;
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return e.code;
    }
  }

  // đăng xuất
  Future signOut() async {
    try {
      // đăng xuất firebase
      await _auth.signOut();

      // đăng xuất Google account nếu có
      await GoogleSignIn().signOut();
    } catch (e) {
      print(e);
      return e;
    }
  }

  // đăng nhập với email và password
  Future signInWithEmailAndPassword(email, password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      print(e.code.toString());
      return e.code.toString();
    } catch (e) {
      print(e);
      return e.code;
    }
  }

  // đăng ký với email và password
  Future signUpWithEmailAndPassword(email, password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      print(e.code.toString());
      return e.code.toString();
    } catch (e) {
      print(e);
      return e;
    }
  }

  // đăng nhập với tài khoản Google
  Future signInWithGoogleAccount() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseException catch (e) {
      print(e.code);
      return e.code;
    } catch (e) {
      print(e);
      return e;
    }
  }
}