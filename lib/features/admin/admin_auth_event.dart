part of 'admin_auth_bloc.dart';

abstract class AdminAuthEvent extends Equatable {
  const AdminAuthEvent();
  @override
  List<Object?> get props => [];
}

class AdminSignInRequested extends AdminAuthEvent {
  final String email;
  final String password;
  const AdminSignInRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class AdminGoogleSignInRequested extends AdminAuthEvent {}

class AdminSignOutRequested extends AdminAuthEvent {}

class AdminForgotPasswordRequested extends AdminAuthEvent {
  final String email;
  const AdminForgotPasswordRequested(this.email);
  @override
  List<Object?> get props => [email];
}
