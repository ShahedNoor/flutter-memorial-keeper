import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';
import 'package:memorialkeeper/src/features/auth/domain/repositories/auth_repository.dart';

sealed class AuthEvent {
  const AuthEvent();
}

final class LoginRequested extends AuthEvent {
  const LoginRequested({
    this.context,
    required this.email,
    required this.password,
  });

  final BuildContext? context;
  final String email;
  final String password;
}

final class SignUpRequested extends AuthEvent {
  const SignUpRequested({
    this.context,
    required this.name,
    required this.email,
    required this.password,
  });

  final BuildContext? context;
  final String name;
  final String email;
  final String password;
}

final class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested({this.context});

  final BuildContext? context;
}

final class ForgotPasswordRequested extends AuthEvent {
  const ForgotPasswordRequested({
    this.context,
    required this.email,
  });

  final BuildContext? context;
  final String email;
}

final class AuthResetRequested extends AuthEvent {
  const AuthResetRequested();
}

sealed class AuthState {
  const AuthState();

  bool get isLoading => this is AuthLoading;
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthSuccess extends AuthState {
  const AuthSuccess();
}

final class AuthFailure extends AuthState {
  const AuthFailure(this.failure);
  final Failure failure;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository repository})
      : _repository = repository,
        super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthResetRequested>(_onResetRequested);
  }

  final AuthRepository _repository;

  void _onResetRequested(
    AuthResetRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthInitial());
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result =
        await _repository.login(email: event.email, password: event.password);

    result.fold(
      (failure) {
        emit(AuthFailure(failure));
        final ctx = event.context;
        if (ctx != null && ctx.mounted) {
          showToast(ctx, message: failure.message, status: 'error');
        }
      },
      (_) {
        emit(const AuthSuccess());
        final ctx = event.context;
        if (ctx != null && ctx.mounted) {
          showToast(ctx, message: 'Signed in successfully', status: 'success');
        }
      },
    );
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _repository.signUp(
      name: event.name,
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) {
        emit(AuthFailure(failure));
        final ctx = event.context;
        if (ctx != null && ctx.mounted) {
          showToast(ctx, message: failure.message, status: 'error');
        }
      },
      (_) {
        emit(const AuthSuccess());
        final ctx = event.context;
        if (ctx != null && ctx.mounted) {
          showToast(ctx, message: 'Account created successfully', status: 'success');
        }
      },
    );
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _repository.loginWithGoogle();

    result.fold(
      (failure) {
        // If user just cancelled the popup, don't scream error toast
        if (failure.message.contains('cancelled')) {
          emit(const AuthInitial());
          return;
        }
        emit(AuthFailure(failure));
        final ctx = event.context;
        if (ctx != null && ctx.mounted) {
          showToast(ctx, message: failure.message, status: 'error');
        }
      },
      (_) {
        emit(const AuthSuccess());
        final ctx = event.context;
        if (ctx != null && ctx.mounted) {
          showToast(ctx, message: 'Signed in with Google', status: 'success');
        }
      },
    );
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _repository.forgotPassword(email: event.email);

    result.fold(
      (failure) {
        emit(AuthFailure(failure));
        final ctx = event.context;
        if (ctx != null && ctx.mounted) {
          showToast(ctx, message: failure.message, status: 'error');
        }
      },
      (_) {
        emit(const AuthSuccess());
        final ctx = event.context;
        if (ctx != null && ctx.mounted) {
          showToast(
            ctx,
            message: 'Password reset link sent successfully',
            status: 'success',
          );
        }
      },
    );
  }
}
