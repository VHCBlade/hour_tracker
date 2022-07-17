import 'package:event_bloc/event_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hour_tracker/bloc/events.dart';
import 'package:hour_tracker/model/category.dart';
import 'package:hour_tracker/model/hour_log.dart';
import 'package:hour_tracker/screens/hour_log/category.dart';
import 'package:hour_tracker/screens/hour_log/list.dart';

class HourLogScreen extends StatefulWidget {
  final CategoryModel? category;

  const HourLogScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<HourLogScreen> createState() => _HourLogScreenState();
}

class _HourLogScreenState extends State<HourLogScreen> {
  late final eventListener =
      BlocEventChannel.simpleListener((_) => setState(() {}));
  late final BlocEventChannel eventChannel;

  @override
  void initState() {
    super.initState();
    eventChannel = BlocEventChannelProvider.of(context);
    eventChannel.addEventListener(
        HourTrackerEvents.changeCategory.toString(), eventListener);
  }

  @override
  void dispose() {
    eventChannel.removeEventListener(
        HourTrackerEvents.changeCategory.toString(), eventListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category?.name ?? "Error"),
      ),
      body: widget.category == null
          ? Text("No Category Found!",
              style: Theme.of(context).textTheme.displayLarge)
          : Column(children: [
              HourLogCategoryWidget(model: widget.category!),
              Expanded(child: HourLogListWidget(model: widget.category!)),
            ]),
      floatingActionButton: widget.category == null
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AddHourLogDialog(model: widget.category!)),
            ),
    );
  }
}

class AddHourLogDialog extends StatefulWidget {
  const AddHourLogDialog({Key? key, required this.model}) : super(key: key);
  final CategoryModel model;

  @override
  State<AddHourLogDialog> createState() => _AddHourLogDialogState();
}

class _AddHourLogDialogState extends State<AddHourLogDialog> {
  late final TextEditingController controller;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    focusNode = FocusNode();
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Add Hour Log"),
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
              final newHours = int.tryParse(value);
              if (newHours == null) {
                return;
              }
              if (newHours > 0) {
                final hourLog = HourLogModel();
                hourLog.logTime = DateTime.now();
                hourLog.category = widget.model.id!;
                hourLog.hours = newHours.toDouble();

                BlocEventChannelProvider.of(context)
                    .fireEvent(HourTrackerEvents.addLog.toString(), hourLog);
              }
              Navigator.of(context).pop();
            },
          ),
        )
      ],
    );
  }
}
