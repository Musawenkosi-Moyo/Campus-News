import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(code: 'cancelled', message: 'Sign‑in cancelled');
    }
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCred = await _auth.signInWithCredential(credential);
    final uid = userCred.user?.uid;
    final email = userCred.user?.email ?? '';
    if (uid == null) {
      throw FirebaseAuthException(code: 'no-uid', message: 'User uid missing');
    }

    String role = 'user';
    if (email.toLowerCase().endsWith('@admin.nust.ac.zw')) {
      role = 'admin';
    } else if (email.toLowerCase().endsWith('@gmail.com')) {
      role = 'user'; 
    } else if (email.toLowerCase().endsWith('@students.nust.ac.zw')) {
      role = 'user';
    }

    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
    final docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': uid,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await userDoc.update({'role': role});
    }
    return role;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
