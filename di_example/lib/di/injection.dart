import 'package:get_it/get_it.dart';

import '../core/counter_service.dart';
import '../core/counter_service_impl.dart';

final getIt = GetIt.instance;

void setupInjection() {
  getIt.registerLazySingleton<CounterService>(() => CounterServiceImpl());
}
