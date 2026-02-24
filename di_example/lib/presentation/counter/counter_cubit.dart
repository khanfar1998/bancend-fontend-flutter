import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/counter_service.dart';

class CounterCubit extends Cubit<int> {
  final CounterService _counterService;

  CounterCubit(this._counterService) : super(0) {
    emit(_counterService.count);
  }


  void increment() {
    _counterService.increment();
    emit(_counterService.count);
  }
}
