/// Service for counter value. Injected via get_it.
abstract class CounterService {
  int get count;
  void increment();
}
