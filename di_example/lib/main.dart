import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/counter_service.dart';
import 'di/injection.dart';
import 'presentation/counter/counter_cubit.dart';
import 'presentation/counter/counter_screen.dart';

void main() {
  setupInjection();
  runApp(const DiExampleApp());
}

class DiExampleApp extends StatelessWidget {
  const DiExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter DI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocProvider<CounterCubit>(
        create: (_) => CounterCubit(getIt<CounterService>()),
        child: const CounterScreen(),
      ),
    );
  }
}
