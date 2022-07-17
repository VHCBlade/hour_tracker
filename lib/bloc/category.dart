import 'package:event_bloc/event_bloc_no_widgets.dart';
import 'package:hour_tracker/model/category.dart';
import 'package:hour_tracker/repository/database/database.dart';
import 'package:search_me_up/search_me_up.dart';

import 'events.dart';

const CATEGORY_DB = 'category';

class CategoryBloc extends Bloc {
  @override
  final BlocEventChannel eventChannel;
  final DatabaseRepository repo;
  final Map<String, CategoryModel> map = {};
  final Set<String> ignoreSet = <String>{};

  CategoryBloc({required this.repo, BlocEventChannel? parentChannel})
      : eventChannel = BlocEventChannel(parentChannel) {
    eventChannel.addEventListener(HourTrackerEvents.addCategory.toString(),
        BlocEventChannel.simpleListener((val) => addCategory(val)));
    eventChannel.addEventListener(HourTrackerEvents.changeCategory.toString(),
        BlocEventChannel.simpleListener((val) => _updateCategories(val)));
  }

  final SearchMeUp<CategoryModel> searchMeUp =
      SearchMeUp(DefaultSearchMeUpDelegate(converters: [
    (category) => [category.name!]
  ]));

  String? searchTerm;

  bool isLoading = false;

  CategoryModel getCategoryFromIndex(int index) => map[categories.list[index]]!;

  final SortedSearchList<CategoryModel, String> categories = SortedSearchList(
      comparator: (a, b) => (b.ordinal ?? -1).compareTo(a.ordinal ?? -1),
      converter: (model) => model.id!);

  Future loadCategories() async {
    isLoading = true;
    Future.delayed(Duration.zero).then((value) => updateBloc());
    final models =
        await repo.findAllModelsOfType(CATEGORY_DB, () => CategoryModel());
    isLoading = false;
    _addCategories(models);

    regenerateBlocValues();
  }

  void moveElementInList(int oldIndex, int newIndex) {
    assert(oldIndex > -1 && oldIndex < categories.list.length);
    assert(newIndex > -1 && newIndex < categories.list.length);

    final indices = [];

    getCategoryFromIndex(oldIndex).ordinal =
        getOrdinal(categories.list.length, newIndex);
    indices.add(oldIndex);

    for (int i = 0; i < categories.list.length; i++) {
      final pastOldIndex = i >= oldIndex;
      final pastNewIndex = i >= newIndex;

      if (!pastOldIndex && !pastNewIndex) {
        continue;
      }
      if (pastNewIndex && pastOldIndex) {
        break;
      }
      indices.add(i);
      if (pastNewIndex) {
        getCategoryFromIndex(i).ordinal =
            getOrdinal(categories.list.length, i + 1);
      }
      if (pastOldIndex) {
        getCategoryFromIndex(i + 1).ordinal =
            getOrdinal(categories.list.length, i);
      }
    }

    indices
        .map((index) => getCategoryFromIndex(index))
        .forEach((element) => repo.saveModel(CATEGORY_DB, element));

    regenerateBlocValues();
  }

  int getOrdinal(int length, int place) => length - place - 1;

  void regenerateBlocValues() {
    categories.generateSearchList(
        searchTerm: searchTerm,
        values: map.values.where(
            (element) => !ignoreSet.contains(element.name?.toUpperCase())),
        searchMeUp: searchMeUp);
    updateBloc();
  }

  void _addCategories(Iterable<CategoryModel> models) {
    models
        .where((element) => !map.containsKey(element.id))
        .forEach((element) => map[element.id!] = element);
  }

  void _updateCategories(CategoryModel model) {
    repo.saveModel(CATEGORY_DB, model);
    updateBloc();
  }

  Future loadIgnoreSet(Iterable<String> ignoreSet) async {
    this.ignoreSet.clear();
    this.ignoreSet.addAll(ignoreSet.map((e) => e.toUpperCase()));
    regenerateBlocValues();
  }

  Future clearIgnoreSet(Set<String> ignoreSet) async {
    this.ignoreSet.clear();
    regenerateBlocValues();
  }

  Future<CategoryModel> addCategory(String category) async {
    final newCategory = CategoryModel();
    newCategory.name = category;
    newCategory.ordinal = categories.list.length;
    final savedCategory = await repo.saveModel(CATEGORY_DB, newCategory);

    _addCategories([savedCategory]);
    regenerateBlocValues();
    return savedCategory;
  }
}
