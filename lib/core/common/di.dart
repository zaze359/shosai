import 'package:get_it/get_it.dart';
import 'package:shosai/core/data/repository/book_repository.dart';
import 'package:shosai/core/database/dao/book_dao.dart';



void initDi() {
  Injector injector = Injector.instance;
  injector.registerLazySingleton<BookDao>(() => BookDao());
  injector.registerLazySingleton<BookRepository>(() => BookRepositoryImpl(injector.get()));
}

abstract class Injector {
  static final Injector _instance = _InjectorImplementation();
  static Injector get instance => _instance;

  void registerFactory<T extends Object>(FactoryFunc<T> factoryFunc, {
    String? instanceName,
  });

  T registerSingleton<T extends Object>(T instance, {
    String? instanceName,
    bool? signalsReady,
    DisposingFunc<T>? dispose,
  });

  void registerLazySingleton<T extends Object>(FactoryFunc<T> factoryFunc, {
    String? instanceName,
    DisposingFunc<T>? dispose,
  });

  T get<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
  });
}

class _InjectorImplementation implements Injector {
  // 使用单独的 git_it。
  static final GetIt _provider = GetIt.instance;

  @override
  void registerFactory<T extends Object>(FactoryFunc<T> factoryFunc,
      {String? instanceName}) {
    _provider.registerFactory(factoryFunc, instanceName: instanceName);
  }


  @override
  T registerSingleton<T extends Object>(T instance,
      {String? instanceName, bool? signalsReady, DisposingFunc<T>? dispose}) {
    return _provider.registerSingleton<T>(instance, instanceName: instanceName,
        signalsReady: signalsReady,
        dispose: dispose);
  }

  @override
  void registerLazySingleton<T extends Object>(FactoryFunc<T> factoryFunc,
      {String? instanceName, DisposingFunc<T>? dispose}) {
    return _provider.registerLazySingleton<T>(
        factoryFunc, instanceName: instanceName, dispose: dispose);
  }

  @override
  T get<T extends Object>({String? instanceName, param1, param2}) {
    return _provider.get(instanceName: instanceName, param1: param1, param2: param2);
  }

}

