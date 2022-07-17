import 'package:hour_tracker/model/model.dart';
import 'package:tuple/tuple.dart';

class HourLogModel extends GenericModel {
  static const TYPE = "hour_log";

  static const LOG_TIME = "log_time";
  static const HOURS = "hours";
  static const CATEGORY = "category";

  DateTime? logTime;
  double? hours;
  String? category;

  @override
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap() => {
        LOG_TIME: Tuple2(() => logTime?.microsecondsSinceEpoch,
            (val) => logTime = DateTime.fromMicrosecondsSinceEpoch(val)),
        HOURS: Tuple2(() => hours, (val) => hours = val),
        CATEGORY: Tuple2(() => category, (val) => category = val),
      };

  @override
  String get type => TYPE;
}
