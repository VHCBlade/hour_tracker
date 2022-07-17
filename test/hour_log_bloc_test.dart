import 'package:flutter_test/flutter_test.dart';
import 'package:hour_tracker/bloc/category.dart';
import 'package:hour_tracker/bloc/events.dart';
import 'package:hour_tracker/bloc/hour_log.dart';
import 'package:hour_tracker/model/category.dart';
import 'package:hour_tracker/model/hour_log.dart';
import 'package:hour_tracker/repository/database/memory.dart';

import 'category_bloc_test.dart';

void main() {
  group('Hour Log', () {
    test('Add', addCheck);
    test('Load', loadCheck);
    test('Update', updateCheck);
    group("Category", () {
      test("Status", statusCheck);
      test("Statuses", statusesCheck);
    });
  });
}

void addCheck() async {
  final repo = MemoryDBRepository();

  final bloc = HourLogBloc(repo: repo);

  bloc.eventChannel.fireEvent(
      HourTrackerEvents.addLog.toString(),
      HourLogModel()
        ..hours = 20
        ..category = "1"
        ..logTime = DateTime.now());
  await Future.delayed(Duration.zero);

  expect(bloc.getLoggedHoursForCategory("1"), 20);

  bloc.eventChannel.fireEvent(
      HourTrackerEvents.addLog.toString(),
      HourLogModel()
        ..hours = 10
        ..category = "1"
        ..logTime = DateTime.now());
  await Future.delayed(Duration.zero);
  bloc.eventChannel.fireEvent(
      HourTrackerEvents.addLog.toString(),
      HourLogModel()
        ..hours = 15
        ..category = "2"
        ..logTime = DateTime.now());
  await Future.delayed(Duration.zero);

  expect(bloc.getLoggedHoursForCategory("1"), 30);
  expect(bloc.getLoggedHoursForCategory("2"), 15);
}

void loadCheck() async {
  final repo = MemoryDBRepository();

  final bloc = HourLogBloc(repo: repo);

  bloc.eventChannel.fireEvent(
      HourTrackerEvents.addLog.toString(),
      HourLogModel()
        ..hours = 20
        ..category = "1"
        ..logTime = DateTime.now());
  await Future.delayed(Duration.zero);
  bloc.eventChannel.fireEvent(
      HourTrackerEvents.addLog.toString(),
      HourLogModel()
        ..hours = 10
        ..category = "1"
        ..logTime = DateTime.now());
  await Future.delayed(Duration.zero);
  bloc.eventChannel.fireEvent(
      HourTrackerEvents.addLog.toString(),
      HourLogModel()
        ..hours = 15
        ..category = "2"
        ..logTime = DateTime.now());
  await Future.delayed(Duration.zero);

  final loadBloc = HourLogBloc(repo: repo);
  loadBloc.loadHourLogs();
  await Future.delayed(Duration.zero);

  expect(loadBloc.getLoggedHoursForCategory("1"), 30);
  expect(loadBloc.getLoggedHoursForCategory("2"), 15);
}

void updateCheck() async {
  final repo = MemoryDBRepository();

  final bloc = HourLogBloc(repo: repo);

  final model = await bloc.addLog(HourLogModel()
    ..hours = 20
    ..category = "1"
    ..logTime = DateTime.now());
  final newModel = HourLogModel()..loadFromMap(model.toMap());
  newModel.hours = 10;
  bloc.eventChannel.fireEvent(HourTrackerEvents.changeLog.toString(), newModel);
  await Future.delayed(Duration.zero);
  expect(bloc.getLoggedHoursForCategory("1"), 10);
}

void statusCheck() async {
  final repo = MemoryDBRepository();
  final categoryBloc = CategoryBloc(repo: repo);
  final bloc = HourLogBloc(repo: repo);

  final categoryModel = await categoryBloc.addCategory("Cool");

  expect(bloc.getStatusForCategory(categoryModel), CategoryStatus.New);

  bloc.eventChannel.fireEvent(
      HourTrackerEvents.addLog.toString(),
      HourLogModel()
        ..hours = 20
        ..category = categoryModel.id
        ..logTime = DateTime.now());
  await Future.delayed(Duration.zero);

  expect(bloc.getStatusForCategory(categoryModel), CategoryStatus.Unlimited);

  bloc.eventChannel.fireEvent(HourTrackerEvents.changeCategory.toString(),
      categoryModel..hourGoal = 30);
  await Future.delayed(Duration.zero);

  expect(bloc.getStatusForCategory(categoryModel), CategoryStatus.Ongoing);

  bloc.eventChannel.fireEvent(HourTrackerEvents.changeCategory.toString(),
      categoryModel..hourGoal = 10);
  await Future.delayed(Duration.zero);

  expect(bloc.getStatusForCategory(categoryModel), CategoryStatus.Completed);
}

void statusesCheck() async {
  final repoBloc = await createBlocAndLoad5Categories();
  final hourBloc = HourLogBloc(repo: repoBloc.item1);
  final categoryBloc = repoBloc.item2;

  expect(hourBloc.getStatusCountsFromCategories(categoryBloc.map.values), {
    CategoryStatus.Completed: 0,
    CategoryStatus.Ongoing: 0,
    CategoryStatus.New: 5,
    CategoryStatus.Unlimited: 0
  });

  hourBloc.eventChannel.fireEvent(
      HourTrackerEvents.addLog.toString(),
      HourLogModel()
        ..hours = 20
        ..category = categoryBloc.getCategoryFromIndex(0).id
        ..logTime = DateTime.now());
  await Future.delayed(Duration.zero);

  hourBloc.eventChannel.fireEvent(
      HourTrackerEvents.addLog.toString(),
      HourLogModel()
        ..hours = 20
        ..category = categoryBloc.getCategoryFromIndex(1).id
        ..logTime = DateTime.now());
  await Future.delayed(Duration.zero);

  hourBloc.eventChannel.fireEvent(
      HourTrackerEvents.addLog.toString(),
      HourLogModel()
        ..hours = 20
        ..category = categoryBloc.getCategoryFromIndex(2).id
        ..logTime = DateTime.now());
  await Future.delayed(Duration.zero);

  expect(hourBloc.getStatusCountsFromCategories(categoryBloc.map.values), {
    CategoryStatus.Completed: 0,
    CategoryStatus.Ongoing: 0,
    CategoryStatus.New: 2,
    CategoryStatus.Unlimited: 3
  });

  categoryBloc.eventChannel.fireEvent(
      HourTrackerEvents.changeCategory.toString(),
      categoryBloc.getCategoryFromIndex(1)..hourGoal = 30);
  await Future.delayed(Duration.zero);

  categoryBloc.eventChannel.fireEvent(
      HourTrackerEvents.changeCategory.toString(),
      categoryBloc.getCategoryFromIndex(0)..hourGoal = 10);
  await Future.delayed(Duration.zero);

  expect(hourBloc.getStatusCountsFromCategories(categoryBloc.map.values), {
    CategoryStatus.Completed: 1,
    CategoryStatus.Ongoing: 1,
    CategoryStatus.New: 2,
    CategoryStatus.Unlimited: 1
  });
}
