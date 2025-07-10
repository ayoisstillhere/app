import 'package:app/features/chat/data/datasources/firebase_remote_datasource.dart';
import 'package:app/features/chat/data/repositories/firebase_repository_impl.dart';
import 'package:app/features/chat/domain/repositories/firebase_repository.dart';
import 'package:app/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //Features bloc,
  sl.registerFactory<ChatCubit>(() => ChatCubit(getMessagesUsecase: sl.call()));
  //!useCase
  sl.registerLazySingleton<GetMessagesUsecase>(
    () => GetMessagesUsecase(repository: sl.call()),
  );
  //repository
  sl.registerLazySingleton<FirebaseRepository>(
    () => FirebaseRepositoryImpl(firebaseRemoteDatasource: sl.call()),
  );
  //datasource
  sl.registerLazySingleton<FirebaseRemoteDataSource>(
      () => FirebaseRemoteDatasourceImpl());
  //external
  //e.g final shared Preference = await SharedPreferences.getInstance();
}
