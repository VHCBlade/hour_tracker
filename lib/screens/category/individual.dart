import 'package:event_bloc/event_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hour_tracker/bloc/hour_log.dart';
import 'package:hour_tracker/model/category.dart';

class CategoryWidget extends StatelessWidget {
  final CategoryModel category;
  final void Function() action;

  const CategoryWidget({Key? key, required this.category, required this.action})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final hourLogBloc = BlocProvider.watch<HourLogBloc>(context);

    return Card(
      child: GestureDetector(
        onTap: action,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(children: [
            Expanded(
                child: Text(category.name!,
                    style: Theme.of(context).textTheme.headline6)),
            if (!hourLogBloc.isLoading)
              Text(hourLogBloc.getStatusForCategory(category).name),
            const Icon(Icons.chevron_right),
            const SizedBox(height: 50)
          ]),
        ),
      ),
    );
  }
}
