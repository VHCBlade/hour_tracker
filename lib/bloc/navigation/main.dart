import 'package:event_bloc/event_bloc.dart';
import 'package:event_navigation/event_navigation.dart';

const POSSIBLE_NAVIGATION = {'home'};

MainNavigationBloc<String> generateNavigationBloc(
    {BlocEventChannel? parentChannel}) {
  final bloc = MainNavigationBloc<String>(
      parentChannel: parentChannel,
      strategy: ListNavigationStrategy(
        possibleNavigations: POSSIBLE_NAVIGATION.toList(),
        defaultNavigation: 'home',
      ),
      undoStrategy: UndoRedoMainNavigationStrategy());

  return bloc;
}
