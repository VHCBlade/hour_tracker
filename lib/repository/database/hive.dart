import 'dart:async';

import 'package:event_bloc/event_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hour_tracker/model/category.dart';
import 'package:hour_tracker/model/hour_log.dart';
import 'package:hour_tracker/model/model.dart';
import 'package:hour_tracker/repository/database/database.dart';

const INCREMENTER_KEY = "incrementer";

class HiveRepository extends DatabaseRepository {
  late final Future initialized;
  @override
  void initialize(BlocEventChannel channel) async {
    final completer = Completer();
    initialized = completer.future;
    super.initialize(channel);
    await Hive.initFlutter();
    Hive.registerAdapter(
        GenericTypeAdapter<CategoryModel>(() => CategoryModel()));
    Hive.registerAdapter(
        GenericTypeAdapter<HourLogModel>(() => HourLogModel()));
    completer.complete();
  }

  Future<LazyBox> openBox(String database) async {
    await initialized;
    return Hive.openLazyBox(database);
  }

  Future<int> getNextSequence(String database) async {
    final box = await openBox(database);
    int id = await box.get(INCREMENTER_KEY, defaultValue: 100);

    id++;
    box.put(INCREMENTER_KEY, id);

    return id;
  }

  @override
  Future<T> saveModel<T extends GenericModel>(String database, T model) async {
    final box = await openBox(database);

    if (model.id == null) {
      final newId = await getNextSequence(database);
      model.id = '${model.type}::$newId';
    }

    await box.put(model.id, model);
    return model;
  }

  @override
  Future<bool> deleteModel<T extends GenericModel>(
      String database, T model) async {
    if (model.id == null) {
      return false;
    }

    final box = await openBox(database);
    if (!box.containsKey(model.id)) {
      return false;
    }

    box.delete(model.id);

    return true;
  }

  @override
  Future<T?> findModel<T extends GenericModel>(
      String database, String key) async {
    final box = await openBox(database);
    return box.get(key) as T;
  }

  @override
  Future<Iterable<T>> findAllModelsOfType<T extends GenericModel>(
      String database, T Function() supplier) async {
    final type = supplier().type;

    final box = await openBox(database);
    return Future.wait(box.keys
        .where((val) => '$val'.startsWith('$type::'))
        .map((key) async => (await box.get(key)) as T));
  }
}
