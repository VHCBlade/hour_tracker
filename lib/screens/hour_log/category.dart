import 'package:event_bloc/event_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hour_tracker/bloc/events.dart';
import 'package:hour_tracker/bloc/hour_log.dart';
import 'package:hour_tracker/model/category.dart';

class HourLogCategoryWidget extends StatelessWidget {
  const HourLogCategoryWidget({Key? key, required this.model})
      : super(key: key);
  final CategoryModel model;

  @override
  Widget build(BuildContext context) {
    final hourLogBloc = BlocProvider.watch<HourLogBloc>(context);
    final hoursLogged = hourLogBloc.getLoggedHoursForCategory(model.id!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          Row(children: [
            Expanded(
                child: Text(model.name!,
                    style: Theme.of(context).textTheme.headline6)),
            TextButton(
              child: const Icon(Icons.edit),
              onPressed: () => showDialog(
                  context: context,
                  builder: (_) => ChangeCategoryNameDialog(model: model)),
            ),
          ]),
          Row(children: [
            Text("Status: ", style: Theme.of(context).textTheme.labelLarge),
            Text(hourLogBloc.getStatusForCategory(model).name,
                style: Theme.of(context).textTheme.bodyLarge),
          ]),
          Row(children: [
            Text("Hours Logged: ",
                style: Theme.of(context).textTheme.labelLarge),
            Text(hoursLogged == 0 ? "None" : "${hoursLogged.toInt()} Hours",
                style: Theme.of(context).textTheme.bodyLarge),
          ]),
          Row(children: [
            Text("Goal Hours: ", style: Theme.of(context).textTheme.labelLarge),
            Expanded(
                child: Text(
                    model.hourGoal == null ? "None" : "${model.hourGoal} Hours",
                    style: Theme.of(context).textTheme.bodyLarge)),
            TextButton(
              child: const Icon(Icons.edit),
              onPressed: () => showDialog(
                  context: context,
                  builder: (_) => ChangeCategoryGoalDialog(model: model)),
            ),
          ]),
        ]),
      ),
    );
  }
}

class ChangeCategoryNameDialog extends StatefulWidget {
  const ChangeCategoryNameDialog({Key? key, required this.model})
      : super(key: key);
  final CategoryModel model;

  @override
  State<ChangeCategoryNameDialog> createState() =>
      _ChangeCategoryNameDialogState();
}

class _ChangeCategoryNameDialogState extends State<ChangeCategoryNameDialog> {
  late final TextEditingController controller;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.model.name!);
    focusNode = FocusNode();
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Change Category Name"),
      children: [
        Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(hintText: "Name"),
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  widget.model.name = value;
                  BlocEventChannelProvider.of(context).fireEvent(
                      HourTrackerEvents.changeCategory.toString(),
                      widget.model);
                }
                Navigator.of(context).pop();
              },
            ))
      ],
    );
  }
}

class ChangeCategoryGoalDialog extends StatefulWidget {
  const ChangeCategoryGoalDialog({Key? key, required this.model})
      : super(key: key);
  final CategoryModel model;

  @override
  State<ChangeCategoryGoalDialog> createState() =>
      _ChangeCategoryGoalDialogState();
}

class _ChangeCategoryGoalDialogState extends State<ChangeCategoryGoalDialog> {
  late final TextEditingController controller;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: "${widget.model.hourGoal ?? ""}");
    focusNode = FocusNode();
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Change Category Goal Hours"),
      children: [
        Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: const TextInputType.numberWithOptions(),
              decoration: const InputDecoration(hintText: "Hours"),
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                final newHours = int.tryParse(value.isEmpty ? "0" : value);
                if (newHours == null) {
                  return;
                }
                widget.model.hourGoal = newHours <= 0 ? null : newHours;
                BlocEventChannelProvider.of(context).fireEvent(
                    HourTrackerEvents.changeCategory.toString(), widget.model);
                Navigator.of(context).pop();
              },
            ))
      ],
    );
  }
}
