import 'package:event_bloc/event_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:hour_tracker/repository/database/database.dart';
import 'package:hour_tracker/repository/database/hive.dart';

class RepositoryLayer extends StatelessWidget {
  final Widget child;

  const RepositoryLayer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<DatabaseRepository>(
        create: (_) => HiveRepository(), child: child);
  }
}
