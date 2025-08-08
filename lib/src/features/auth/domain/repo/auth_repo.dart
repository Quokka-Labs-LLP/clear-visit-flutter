import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthRepo {
  Future<void> signInWithApple();
  Future<Either<String, GoogleSignInAccount>> signInWithGoogle();
  Future<Either<String, String>> setUsername({required String username, required bool fromSignUpPage});
  Future<void> signOut();
}
