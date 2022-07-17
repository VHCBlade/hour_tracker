import 'package:event_bloc/event_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hour_tracker/bloc/events.dart';
import 'package:hour_tracker/bloc/hour_log.dart';
import 'package:hour_tracker/model/category.dart';
import 'package:hour_tracker/model/hour_log.dart';
import 'package:intl/intl.dart';

final dateFormatter = DateFormat("yyyy-MM-dd HH:mm");

class HourLogListWidget extends StatelessWidget {
  final CategoryModel model;

  const HourLogListWidget({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hourLogBloc = BlocProvider.watch<HourLogBloc>(context);
    final hourLogs = hourLogBloc.categoryMap[model.id!];

    return ListView.builder(
      itemBuilder: (_, index) =>
          HourLogWidget(hourLog: hourLogBloc.map[hourLogs![index]]!),
      itemCount: hourLogs?.length ?? 0,
    );
  }
}

class HourLogWidget extends StatelessWidget {
  final HourLogModel hourLog;

  const HourLogWidget({Key? key, required this.hourLog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: GestureDetector(
        onTap: () => showDialog(
            context: context,
            builder: (_) => UpdateHourLogHoursDialog(model: hourLog)),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(children: [
            Expanded(
                child: Text("${hourLog.hours!.toInt()} Hours",
                    style: Theme.of(context).textTheme.headline6)),
            Text(dateFormatter.format(hourLog.logTime!)),
            const Icon(Icons.chevron_right),
            const SizedBox(height: 50)
          ]),
        ),
      ),
    );
  }
}

class UpdateHourLogHoursDialog extends StatefulWidget {
  const UpdateHourLogHoursDialog({Key? key, required this.model})
      : super(key: key);
  final HourLogModel model;

  @override
  State<UpdateHourLogHoursDialog> createState() =>
      _UpdateHourLogHoursDialogState();
}

class _UpdateHourLogHoursDialogState extends State<UpdateHourLogHoursDialog> {
  late final TextEditingController controller;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: "${widget.model.hours!.toInt()}");
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
                widget.model.hours = newHours.toDouble();

                BlocEventChannelProvider.of(context).fireEvent(
                    HourTrackerEvents.changeLog.toString(), widget.model);
              }
              Navigator.of(context).pop();
            },
          ),
        )
      ],
    );
  }
}
