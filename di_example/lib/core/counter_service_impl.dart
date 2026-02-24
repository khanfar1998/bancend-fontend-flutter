import 'counter_service.dart';

class CounterServiceImpl implements CounterService {
  CounterServiceImpl() : _count = 0;

  int _count;

  @override
  int get count => _count;

  @override
  void increment() {
    _count++;
  }
}
