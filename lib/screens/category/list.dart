import 'package:flutter/material.dart';
import 'package:event_bloc/event_bloc.dart';
import 'package:hour_tracker/bloc/category.dart';
import 'package:hour_tracker/bloc/events.dart';
import 'package:hour_tracker/screens/category/count.dart';
import 'package:hour_tracker/screens/category/individual.dart';
import 'package:hour_tracker/screens/hour_log/main.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const AddNewCategoryDialog(),
        ),
      ),
      body: const CategoryScreenBody(),
    );
  }
}

class AddNewCategoryDialog extends StatefulWidget {
  const AddNewCategoryDialog({Key? key}) : super(key: key);

  @override
  State<AddNewCategoryDialog> createState() => _AddNewCategoryDialogState();
}

class _AddNewCategoryDialogState extends State<AddNewCategoryDialog> {
  late final TextEditingController controller;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    focusNode = FocusNode();
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Add new category"),
      children: [
        Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(hintText: "Name"),
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  BlocEventChannelProvider.of(context).fireEvent(
                      HourTrackerEvents.addCategory.toString(), value);
                }
                Navigator.of(context).pop();
              },
            ))
      ],
    );
  }
}

class CategoryScreenBody extends StatelessWidget {
  const CategoryScreenBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryBloc = BlocProvider.watch<CategoryBloc>(context);
    if (categoryBloc.isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    return Column(children: [
      const CategoryStatusCountWidget(),
      Expanded(
        child: ReorderableListView.builder(
          key: UniqueKey(),
          onReorder: (oldIndex, newIndex) => categoryBloc.moveElementInList(
              oldIndex, newIndex > oldIndex ? newIndex - 1 : newIndex),
          itemBuilder: (_, index) => CategoryWidget(
            key: ValueKey(categoryBloc.getCategoryFromIndex(index).id),
            category: categoryBloc.getCategoryFromIndex(index),
            action: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => HourLogScreen(
                    category: categoryBloc.getCategoryFromIndex(index)))),
          ),
          itemCount: categoryBloc.categories.list.length,
        ),
      )
    ]);
  }
}
