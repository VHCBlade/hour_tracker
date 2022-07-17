import 'dart:async';

import 'package:event_bloc/event_bloc.dart';
import 'package:hour_tracker/model/model.dart';
import 'package:hour_tracker/repository/database/database.dart';

class MemoryDBRepository extends DatabaseRepository {
  late final Future initialized;
  int counter = 0;

  final Map<String, Map<String, Map<String, dynamic>>> databaseMap = {};

  @override
  void initialize(BlocEventChannel channel) async {}

  @override
  Future<T> saveModel<T extends GenericModel>(String database, T model) async {
    if (model.id == null) {
      final newId = counter++;
      model.id = '${model.type}::$newId';
    }

    if (!databaseMap.containsKey(model.type)) {
      databaseMap[model.type] = {};
    }

    databaseMap[model.type]![model.id!] = model.toMap();
    return model;
  }

  @override
  Future<bool> deleteModel<T extends GenericModel>(
      String database, T model) async {
    if (model.id == null) {
      return false;
    }

    return databaseMap[model.type]?.remove(model.id) != null;
  }

  @override
  Future<T?> findModel<T extends GenericModel>(
      String database, String key) async {
    throw Exception("Not Yet Implemented!");
  }

  @override
  Future<Iterable<T>> findAllModelsOfType<T extends GenericModel>(
      String database, T Function() supplier) async {
    final type = supplier().type;
    return databaseMap[type]?.values.map((e) => supplier()..loadFromMap(e)) ??
        [];
  }
}
