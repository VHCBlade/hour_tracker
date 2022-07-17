import 'package:event_bloc/event_bloc_no_widgets.dart';
import 'package:hour_tracker/bloc/events.dart';
import 'package:hour_tracker/model/category.dart';
import 'package:hour_tracker/model/hour_log.dart';
import 'package:hour_tracker/repository/database/database.dart';

const HOUR_LOG_DB = 'hour_log';

class HourLogBloc extends Bloc {
  @override
  final BlocEventChannel eventChannel;
  final DatabaseRepository repo;
  final Map<String, HourLogModel> map = {};
  final Map<String, List<String>> categoryMap = {};

  bool isLoading = false;

  HourLogBloc({required this.repo, BlocEventChannel? parentChannel})
      : eventChannel = BlocEventChannel(parentChannel) {
    eventChannel.addEventListener(HourTrackerEvents.addLog.toString(),
        BlocEventChannel.simpleListener((val) => addLog(val)));
    eventChannel.addEventListener(HourTrackerEvents.changeLog.toString(),
        BlocEventChannel.simpleListener((val) => addLog(val)));
  }

  Future loadHourLogs() async {
    isLoading = true;
    Future.delayed(Duration.zero).then((value) => updateBloc());
    final models =
        await repo.findAllModelsOfType(HOUR_LOG_DB, () => HourLogModel());
    models
        .where((element) => element.hours == null)
        .forEach((element) => element.hours = 0);
    isLoading = false;
    _updateLogs(models);
    regenerateBloc();
  }

  void _updateLogs(Iterable<HourLogModel> models) {
    final dirtiedCategories = <String>{};

    for (HourLogModel model in models) {
      final isNew = !map.containsKey(model.id);
      map[model.id!] = model;
      if (isNew) {
        if (!categoryMap.containsKey(model.category)) {
          categoryMap[model.category!] = [];
        }
        categoryMap[model.category!]!.add(model.id!);
      }
      dirtiedCategories.add(model.category!);
    }

    dirtiedCategories.forEach((element) => categoryMap[element]!.sort(
          (a, b) {
            final modelA = map[a]!;
            final modelB = map[b]!;

            return modelB.logTime!.compareTo(modelA.logTime!);
          },
        ));
  }

  Future<HourLogModel> addLog(HourLogModel model) async {
    final savedLog = await repo.saveModel(HOUR_LOG_DB, model);

    _updateLogs([savedLog]);
    regenerateBloc();
    return savedLog;
  }

  void regenerateBloc() {
    updateBloc();
  }

  double getLoggedHoursForCategory(String id) {
    if (!categoryMap.containsKey(id)) {
      return 0;
    }

    return categoryMap[id]!
        .map((element) => map[element]!.hours!)
        .reduce((value, element) => value + element);
  }

  CategoryStatus getStatusForCategory(CategoryModel model) {
    final hours = getLoggedHoursForCategory(model.id!);

    if (model.hourGoal == null) {
      return hours == 0 ? CategoryStatus.New : CategoryStatus.Unlimited;
    }

    return hours >= model.hourGoal!
        ? CategoryStatus.Completed
        : CategoryStatus.Ongoing;
  }

  Map<CategoryStatus, int> getStatusCountsFromCategories(
      Iterable<CategoryModel> models) {
    final retVal = {
      CategoryStatus.Completed: 0,
      CategoryStatus.New: 0,
      CategoryStatus.Ongoing: 0,
      CategoryStatus.Unlimited: 0,
    };

    models
        .map((e) => getStatusForCategory(e))
        .forEach((element) => retVal[element] = retVal[element]! + 1);

    return retVal;
  }
}
