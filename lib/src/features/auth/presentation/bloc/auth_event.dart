part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class OnLoginEvent extends AuthEvent{
  const OnLoginEvent();

  @override
  List<Object?> get props => [];
}

class OnMobileSignInEvent extends AuthEvent {
  final String mobileNumber;

  const OnMobileSignInEvent({required this.mobileNumber});

  @override
  List<Object?> get props => [mobileNumber];
}

class OnSignUpEvent extends AuthEvent {
  final String mobileNumber;

  const OnSignUpEvent({required this.mobileNumber});

  @override
  List<Object?> get props => [mobileNumber];
}

class OnValidateMobileEvent extends AuthEvent {
  final String mobileNumber;

  const OnValidateMobileEvent({required this.mobileNumber});

  @override
  List<Object?> get props => [mobileNumber];
}

class OnNameSubmitted extends AuthEvent {
  final String name;
  final bool fromSignUpPage;

  const OnNameSubmitted({required this.name, this.fromSignUpPage = false});

  @override
  List<Object?> get props => [name];
}
class OnToggleAuthMode extends AuthEvent {

  const OnToggleAuthMode();

  @override
  List<Object?> get props => [];
}

class OnAppleSignInEvent extends AuthEvent {
  const OnAppleSignInEvent();

  @override
  List<Object?> get props => [];
}

class OnGoogleSignInEvent extends AuthEvent {
  const OnGoogleSignInEvent();

  @override
  List<Object?> get props => [];
}
class OnLogout extends AuthEvent {
  const OnLogout();

  @override
  List<Object?> get props => [];
}

class GetUserName extends AuthEvent {
  const GetUserName();

  @override
  List<Object?> get props => [];
}