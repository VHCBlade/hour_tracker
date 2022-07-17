import 'package:hive/hive.dart';
import 'package:hour_tracker/model/category.dart';
import 'package:hour_tracker/model/hour_log.dart';
import 'package:tuple/tuple.dart';

typedef Getter = dynamic Function();
typedef Setter = void Function(dynamic value);

class GenericTypeAdapter<T extends GenericModel> extends TypeAdapter<T> {
  final T Function() generator;
  late final T instance = generator();

  GenericTypeAdapter(this.generator);

  @override
  T read(BinaryReader reader) {
    final model = generator();
    final map = <String, dynamic>{};
    (reader.read() as Map<dynamic, dynamic>)
        .entries
        .forEach((element) => map[element.key] = element.value);
    model.loadFromMap(map);
    return model;
  }

  @override
  int get typeId {
    switch (instance.type) {
      case CategoryModel.TYPE:
        return 0;
      case HourLogModel.TYPE:
        return 1;
      default:
        throw ArgumentError('${instance.type} is not defined!');
    }
  }

  @override
  void write(BinaryWriter writer, T obj) {
    writer.write(obj.toMap());
  }
}

abstract class GenericModel {
  static const TYPE = 'type';
  static const ID = 'id';
  String? id;

  late final Map<String, Tuple2<Getter, Setter>> getterSetterMap =
      _getterSetterMap;
  Map<String, Tuple2<Getter, Setter>> get _getterSetterMap {
    final getterSetterMap = getGetterSetterMap();
    assert(!getterSetterMap.containsKey(TYPE));
    assert(!getterSetterMap.containsKey(ID));
    return getterSetterMap;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map[TYPE] = type;
    if (id != null) {
      map[ID] = id;
    }
    getterSetterMap.keys
        .forEach((element) => map[element] = getterSetterMap[element]!.item1());

    return map;
  }

  void loadFromMap(Map<String, dynamic> map, {bool respectType = true}) {
    if (respectType && map.containsKey(TYPE)) {
      if (map[TYPE] != type) {
        throw ArgumentError('Type in $map does not match $type');
      }
    }
    if (map.containsKey(ID)) {
      id = map[ID];
    }
    getterSetterMap.keys
        .forEach((element) => getterSetterMap[element]!.item2(map[element]));
  }

  /// Copies values from the given [model] into this model.
  ///
  /// If [allowDifferentTypes] is true, the method will continue even if the types and fields in [model] and myself are different. Otherwise, differences will be met with an error.
  ///
  /// [onlyFields] and [exceptFields] can be used to limit the fields that are copied. The two are mutually exclusive and an error will be thrown if both a specified.
  void copy<T extends GenericModel>(T model,
      {bool allowDifferentTypes = false,
      Iterable<String>? onlyFields,
      Iterable<String>? exceptFields}) {
    assert(onlyFields == null || exceptFields == null);
    if (!allowDifferentTypes) {
      assert(type == model.type);
    }
    final keysToBeCopied = getterSetterMap.keys.where((element) {
      if (onlyFields != null) {
        return onlyFields.contains(element);
      }
      if (exceptFields != null) {
        return !exceptFields.contains(element);
      }
      return true;
    }).where((element) => model.getterSetterMap.keys.contains(element));

    keysToBeCopied.forEach((element) {
      getterSetterMap[element]!.item2(model.getterSetterMap[element]!.item1());
    });
  }

  /// Implemented by subclasses to map the getters and setters of the object.
  ///
  /// Cannot have keys that have the values [TYPE] or [ID]
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap();

  /// Unique type to give to the model. Whether or not collision is expected is dependent on the parameters of your system.
  String get type;
}
