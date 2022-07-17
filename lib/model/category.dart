import 'package:hour_tracker/model/model.dart';
import 'package:tuple/tuple.dart';

class CategoryModel extends GenericModel {
  static const TYPE = "category";

  static const HOUR_GOAL = 'hour_goal';
  static const NAME = 'name';
  static const ORDINAL = 'ordinal';

  String? name;
  int? hourGoal;
  int? ordinal;

  @override
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap() => {
        NAME: Tuple2(() => name, (val) => name = val),
        HOUR_GOAL: Tuple2(() => hourGoal, (val) => hourGoal = val),
        ORDINAL: Tuple2(() => ordinal, (val) => ordinal = val),
      };

  @override
  String get type => TYPE;
}

enum CategoryStatus {
  New,
  Ongoing,
  Completed,
  Unlimited,
}
