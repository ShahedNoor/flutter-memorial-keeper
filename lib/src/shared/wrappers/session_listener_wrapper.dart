import 'package:memorialkeeper/src/imports/core_imports.dart';
import 'package:memorialkeeper/src/imports/packages_imports.dart';

import 'package:memorialkeeper/src/features/auth/presentation/providers/session_bloc.dart';
import 'package:memorialkeeper/src/features/memorials/presentation/providers/memorial_bloc.dart';

class SessionListenerWrapper extends StatelessWidget {
  final Widget child;
  const SessionListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listenWhen: (prev, next) => prev.runtimeType != next.runtimeType,
      listener: (context, state) {
        switch (state) {
          case SessionUnknown():
            break;
          case SessionAuthenticated(:final user):
            FlutterNativeSplash.remove();
            context.read<MemorialBloc>().add(SyncMemorialsEvent(userId: user.id));
          case SessionUnauthenticated():
            FlutterNativeSplash.remove();
        }
      },
      child: child,
    );
  }
}
