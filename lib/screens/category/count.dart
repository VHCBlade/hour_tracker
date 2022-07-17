import 'package:event_bloc/event_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hour_tracker/bloc/category.dart';
import 'package:hour_tracker/bloc/hour_log.dart';
import 'package:hour_tracker/model/category.dart';

class CategoryStatusCountWidget extends StatelessWidget {
  const CategoryStatusCountWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final hourLogBloc = BlocProvider.watch<HourLogBloc>(context);
    final categoryBloc = BlocProvider.watch<CategoryBloc>(context);

    final map =
        hourLogBloc.getStatusCountsFromCategories(categoryBloc.map.values);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          Expanded(
            child: CategoryStatusCountIndividualWidget(
              status: CategoryStatus.Completed,
              iconData: Icons.check,
              count: map[CategoryStatus.Completed]!,
            ),
          ),
          Expanded(
            child: CategoryStatusCountIndividualWidget(
              status: CategoryStatus.Ongoing,
              iconData: Icons.access_alarm,
              count: map[CategoryStatus.Ongoing]!,
            ),
          ),
          Expanded(
            child: CategoryStatusCountIndividualWidget(
              status: CategoryStatus.New,
              iconData: Icons.star,
              count: map[CategoryStatus.New]!,
            ),
          ),
          Expanded(
            child: CategoryStatusCountIndividualWidget(
              status: CategoryStatus.Unlimited,
              iconData: Icons.account_tree,
              count: map[CategoryStatus.Unlimited]!,
            ),
          ),
        ]),
      ),
    );
  }
}

class CategoryStatusCountIndividualWidget extends StatelessWidget {
  final CategoryStatus status;
  final int count;
  final IconData iconData;

  const CategoryStatusCountIndividualWidget(
      {Key? key,
      required this.status,
      required this.count,
      required this.iconData})
      : super(key: key);

  Color _getColorForStatus(CategoryStatus status) {
    switch (status) {
      case CategoryStatus.Completed:
        return Colors.green;
      case CategoryStatus.New:
        return Colors.yellow;
      case CategoryStatus.Ongoing:
        return Colors.blue;
      case CategoryStatus.Unlimited:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("$count", style: Theme.of(context).textTheme.headline6),
        Icon(iconData, size: 50, color: _getColorForStatus(status)),
        Text(status.name, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}
