import 'package:event_bloc/event_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:hour_tracker/bloc/category.dart';
import 'package:hour_tracker/bloc/hour_log.dart';
import 'package:hour_tracker/bloc/navigation/main.dart';
import 'package:hour_tracker/repository/database/database.dart';
import 'package:provider/provider.dart';

class BlocLayer extends StatelessWidget {
  final Widget child;

  const BlocLayer({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_, channel) => generateNavigationBloc(parentChannel: channel),
      child: BlocProvider(
        create: (context, channel) => CategoryBloc(
            repo: context.read<DatabaseRepository>(), parentChannel: channel),
        child: BlocProvider(
          create: (context, channel) => HourLogBloc(
              repo: context.read<DatabaseRepository>(), parentChannel: channel),
          child: BlocLayerStartup(child: child),
        ),
      ),
    );
  }
}

class BlocLayerStartup extends StatefulWidget {
  final Widget child;

  const BlocLayerStartup({Key? key, required this.child}) : super(key: key);

  @override
  _BlocLayerStartupState createState() => _BlocLayerStartupState();
}

class _BlocLayerStartupState extends State<BlocLayerStartup> {
  @override
  void initState() {
    super.initState();
    BlocProvider.read<CategoryBloc>(context).loadCategories();
    BlocProvider.read<HourLogBloc>(context).loadHourLogs();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
