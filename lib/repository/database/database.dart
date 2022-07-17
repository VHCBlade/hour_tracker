import 'package:event_bloc/event_bloc.dart';
import 'package:hour_tracker/model/model.dart';

abstract class DatabaseRepository extends Repository {
  Future<Iterable<T>> findAllModelsOfType<T extends GenericModel>(
      String database, T Function() supplier);

  Future<T?> findModel<T extends GenericModel>(String database, String key);

  Future<bool> deleteModel<T extends GenericModel>(String database, T model);

  Future<T> saveModel<T extends GenericModel>(String database, T model);
}
