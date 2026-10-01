import '../../imports/imports.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/providers/session_bloc.dart';


import '../../features/memorials/data/repositories/memorial_repository_impl.dart';
import '../../features/memorials/domain/usecases/get_memorials_usecase.dart';
import '../../features/memorials/domain/usecases/add_memorial_usecase.dart';
import '../../features/memorials/domain/usecases/update_memorial_usecase.dart';
import '../../features/memorials/domain/usecases/delete_memorial_usecase.dart';
import '../../features/memorials/domain/usecases/toggle_favorite_usecase.dart';
import '../../features/memorials/presentation/providers/memorial_bloc.dart';

import '../../features/dua/data/repositories/dua_repository_impl.dart';
import '../../features/dua/domain/usecases/get_duas_usecase.dart';
import '../../features/dua/presentation/providers/dua_cubit.dart';

/// A wrapper to initialize the chosen State Management library.
class StateWrapper extends StatelessWidget {
  final Widget child;

  const StateWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final memorialRepo = MemorialRepositoryImpl();
    final duaRepo = DuaRepositoryImpl();

    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionBloc>(
            create: (_) => SessionBloc(repository: AuthRepositoryImpl())),
        BlocProvider<MemorialBloc>(
          create: (_) => MemorialBloc(
            getMemorialsUseCase: GetMemorialsUseCase(memorialRepo),
            addMemorialUseCase: AddMemorialUseCase(memorialRepo),
            updateMemorialUseCase: UpdateMemorialUseCase(memorialRepo),
            deleteMemorialUseCase: DeleteMemorialUseCase(memorialRepo),
            toggleFavoriteUseCase: ToggleFavoriteUseCase(memorialRepo),
          )..add(const LoadMemorials()),
        ),
        BlocProvider<DuaCubit>(
          create: (_) => DuaCubit(
            getDuasUseCase: GetDuasUseCase(duaRepo),
          )..loadDuas(),
        ),
      ],
      child: child,
    );
  }
}
