import 'package:fpdart/fpdart.dart';

abstract class AuthRepo {
  Future<void> signInWithApple();
  Future<Either<String, void>> signInWithGoogle();
}
