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
class OnToggleAuthMode extends AuthEvent {

  const OnToggleAuthMode();

  @override
  List<Object?> get props => [];
}


