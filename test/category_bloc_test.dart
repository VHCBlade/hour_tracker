import 'package:flutter_test/flutter_test.dart';
import 'package:hour_tracker/bloc/category.dart';
import 'package:hour_tracker/bloc/events.dart';
import 'package:hour_tracker/model/category.dart';
import 'package:hour_tracker/repository/database/database.dart';
import 'package:hour_tracker/repository/database/memory.dart';
import 'package:tuple/tuple.dart';

void main() {
  group('Category', () {
    test('Add', addCheck);
    test('Load', loadCheck);
    test('Reorder', reorderCheck);
    test('Update', updateCheck);
  });
}

void addCheck() async {
  final repo = MemoryDBRepository();

  final bloc = CategoryBloc(repo: repo);

  bloc.eventChannel
      .fireEvent(HourTrackerEvents.addCategory.toString(), "My Category");

  await Future.delayed(Duration.zero);

  expect(bloc.getCategoryFromIndex(0).name, "My Category");

  bloc.eventChannel
      .fireEvent(HourTrackerEvents.addCategory.toString(), "My Category 2");
  await Future.delayed(Duration.zero);

  expect(bloc.getCategoryFromIndex(1).name, "My Category");
  expect(bloc.getCategoryFromIndex(0).name, "My Category 2");
}

Future<Tuple2<DatabaseRepository, CategoryBloc>>
    createBlocAndLoad5Categories() async {
  final repo = MemoryDBRepository();

  final bloc = CategoryBloc(repo: repo);

  bloc.eventChannel
      .fireEvent(HourTrackerEvents.addCategory.toString(), "My Category");
  await Future.delayed(Duration.zero);
  bloc.eventChannel
      .fireEvent(HourTrackerEvents.addCategory.toString(), "My Category 2");
  await Future.delayed(Duration.zero);
  bloc.eventChannel
      .fireEvent(HourTrackerEvents.addCategory.toString(), "My Category 3");
  await Future.delayed(Duration.zero);
  bloc.eventChannel
      .fireEvent(HourTrackerEvents.addCategory.toString(), "My Category 4");
  await Future.delayed(Duration.zero);
  bloc.eventChannel
      .fireEvent(HourTrackerEvents.addCategory.toString(), "My Category 5");
  await Future.delayed(Duration.zero);

  return Tuple2(repo, bloc);
}

void loadCheck() async {
  final repoBloc = await createBlocAndLoad5Categories();

  final loadBloc = CategoryBloc(repo: repoBloc.item1);
  loadBloc.loadCategories();

  await Future.delayed(Duration.zero);
  expect(loadBloc.getCategoryFromIndex(4).name, "My Category");
  expect(loadBloc.getCategoryFromIndex(3).name, "My Category 2");
  expect(loadBloc.getCategoryFromIndex(2).name, "My Category 3");
  expect(loadBloc.getCategoryFromIndex(1).name, "My Category 4");
  expect(loadBloc.getCategoryFromIndex(0).name, "My Category 5");
}

void reorderCheck() async {
  final repoBloc = await createBlocAndLoad5Categories();
  final bloc = repoBloc.item2;

  bloc.moveElementInList(0, 4);
  await Future.delayed(Duration.zero);
  expect(bloc.getCategoryFromIndex(3).name, "My Category");
  expect(bloc.getCategoryFromIndex(2).name, "My Category 2");
  expect(bloc.getCategoryFromIndex(1).name, "My Category 3");
  expect(bloc.getCategoryFromIndex(0).name, "My Category 4");
  expect(bloc.getCategoryFromIndex(4).name, "My Category 5");

  bloc.moveElementInList(3, 1);
  await Future.delayed(Duration.zero);
  expect(bloc.getCategoryFromIndex(1).name, "My Category");
  expect(bloc.getCategoryFromIndex(3).name, "My Category 2");
  expect(bloc.getCategoryFromIndex(2).name, "My Category 3");
  expect(bloc.getCategoryFromIndex(0).name, "My Category 4");
  expect(bloc.getCategoryFromIndex(4).name, "My Category 5");
}

void updateCheck() async {
  final repoBloc = await createBlocAndLoad5Categories();
  final bloc = repoBloc.item2;

  final newModel = CategoryModel()
    ..loadFromMap(bloc.getCategoryFromIndex(2).toMap());
  newModel.name = "Hole in one!";

  bloc.eventChannel
      .fireEvent(HourTrackerEvents.changeCategory.toString(), newModel);
  await Future.delayed(Duration.zero);
  expect(bloc.getCategoryFromIndex(2).name, "Hole in one!");
}
