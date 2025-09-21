part of 'admin_auth_bloc.dart';

abstract class AdminAuthState extends Equatable {
  const AdminAuthState();
  @override
  List<Object?> get props => [];
}

class AdminAuthInitial extends AdminAuthState {}

class AdminAuthLoading extends AdminAuthState {}

class AdminAuthSuccess extends AdminAuthState {}

class AdminAuthFailure extends AdminAuthState {
  final String message;
  const AdminAuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminForgotPasswordEmailSent extends AdminAuthState {}
