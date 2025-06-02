import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'admin_auth_repository.dart';

part 'admin_auth_event.dart';
part 'admin_auth_state.dart';

class AdminAuthBloc extends Bloc<AdminAuthEvent, AdminAuthState> {
  final AdminAuthRepository repository;

  AdminAuthBloc(this.repository) : super(AdminAuthInitial()) {
    on<AdminSignInRequested>((event, emit) async {
      emit(AdminAuthLoading());
      try {
        await repository.signInWithEmail(event.email, event.password);
        emit(AdminAuthSuccess());
      } catch (e) {
        emit(AdminAuthFailure(e.toString()));
      }
    });

    on<AdminGoogleSignInRequested>((event, emit) async {
      emit(AdminAuthLoading());
      try {
        await repository.signInWithGoogle();
        emit(AdminAuthSuccess());
      } catch (e) {
        emit(AdminAuthFailure(e.toString()));
      }
    });

    on<AdminSignOutRequested>((event, emit) async {
      await repository.signOut();
      emit(AdminAuthInitial());
    });

    on<AdminForgotPasswordRequested>((event, emit) async {
      emit(AdminAuthLoading());
      try {
        await repository.sendPasswordResetEmail(event.email);
        emit(AdminForgotPasswordEmailSent());
      } catch (e) {
        emit(AdminAuthFailure(e.toString()));
      }
    });
  }
}
