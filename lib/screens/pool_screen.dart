import 'package:flutter/material.dart';

import '../components/bullet_list_view.dart';
import '../core/constants.dart';
import '../core/modals.dart';
import '../core/profile.dart';
import 'screen.dart';

final class PoolScreen extends Screen {
  const PoolScreen(super.profile, {super.key}) : super(title: 'Pool');

  @override
  State<PoolScreen> createState() => _PoolScreenState();
}

class _PoolScreenState extends State<PoolScreen> {
  late final Profile profile;
  late final PageController pageController;

  int left = 3;
  int right = 1;

  @override
  void initState() {
    pageController = PageController();
    profile = widget.profile;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const numberOfPages = 4;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // The paddings are here so that [PageSwitcher] does not block
          // [PageView]'s content
          PageView(
            controller: pageController,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: _PoolPage(PoolType.daily, profile),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: _PoolPage(PoolType.weekly, profile),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: _PoolPage(PoolType.rewards, profile),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: _PoolPage(PoolType.punishments, profile),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: _PageSwitcher(
              left,
              right,
              onLeftClick: () {
                pageController.animateToPage(
                  left,
                  duration: const Duration(milliseconds: 370),
                  curve: Curves.fastLinearToSlowEaseIn,
                );

                setState(() {
                  left = (left - 1) % numberOfPages;
                  right = (right - 1) % numberOfPages;
                });
              },
              onRightClick: () {
                pageController.animateToPage(
                  right,
                  duration: const Duration(milliseconds: 370),
                  curve: Curves.fastLinearToSlowEaseIn,
                );

                setState(() {
                  left = (left + 1) % numberOfPages;
                  right = (right + 1) % numberOfPages;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PageSwitcher extends StatelessWidget {
  const _PageSwitcher(
    this.left,
    this.right, {
    required this.onLeftClick,
    required this.onRightClick,
  });

  final int left;
  final int right;
  final void Function() onLeftClick;
  final void Function() onRightClick;

  @override
  Widget build(BuildContext context) {
    return Container(
      // TODO: configure ThemeData in Material App if havent already
      color: Theme.of(context).canvasColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // left arrow
          OutlinedButton.icon(
            label: Text(PoolType.values[left].name),
            icon: Icon(Icons.arrow_back),
            onPressed: onLeftClick,
          ),

          // right arrow
          OutlinedButton.icon(
            label: Text(PoolType.values[right].name),
            icon: Icon(Icons.arrow_forward),
            onPressed: onRightClick,
          ),
        ],
      ),
    );
  }
}

class _PoolPage extends StatefulWidget {
  const _PoolPage(this.poolType, this.profile);

  final PoolType poolType;
  final Profile profile;

  void deleteFromPool(final int id) async {
    switch (poolType) {
      case PoolType.daily:
        await profile.deleteFromDailyTaskPool(id);
        return;
      case PoolType.weekly:
        await profile.deleteFromWeeklyTaskPool(id);
        return;
      case PoolType.punishments:
        await profile.deleteFromPunishmentPool(id);
        return;
      case PoolType.rewards:
        await profile.deleteFromRewardPool(id);
        return;
    }
  }

  void addToPool(final dynamic item) async {
    switch (poolType) {
      case PoolType.daily:
        await profile.addToDailyTaskPool(item as Task);
        return;
      case PoolType.weekly:
        await profile.addToWeeklyTaskPool(item as Task);
        return;
      case PoolType.punishments:
        await profile.addToPunishmentPool(item as Punishment);
        return;
      case PoolType.rewards:
        await profile.addToRewardPool(item as Reward);
        return;
    }
  }

  void editPoolItem(final dynamic item) async {
    switch (poolType) {
      case PoolType.daily:
        await profile.updateDailyTaskPoolItem(item as Task);
        return;
      case PoolType.weekly:
        await profile.updateWeeklyTaskPoolItem(item as Task);
        return;
      case PoolType.punishments:
        await profile.updatePunishmentPoolItem(item as Punishment);
        return;
      case PoolType.rewards:
        await profile.updateRewardPoolItem(item as Reward);
        return;
    }
  }

  @override
  State<_PoolPage> createState() => _PoolPageState();
}

class _PoolPageState extends State<_PoolPage> {
  /// if true, then a new item is being added
  bool isAddingNew = false;

  /// if not null, then the page is being edited
  int? editId;

  @override
  Widget build(BuildContext context) {
    final hasStats = (widget.poolType == PoolType.daily) ||
        (widget.poolType == PoolType.weekly);

    late final List pool;

    switch (widget.poolType) {
      case PoolType.daily:
        pool = widget.profile.dailyTaskPool;
        break;
      case PoolType.weekly:
        pool = widget.profile.weeklyTaskPool;
        break;
      case PoolType.punishments:
        pool = widget.profile.punishmentPool;
        break;
      case PoolType.rewards:
        pool = widget.profile.rewardPool;
        break;
    }

    return Column(
      children: [
        // name & add item
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.poolType.name}s',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Card(
              elevation: 0.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    icon: Icon(Icons.add_circle, color: Colors.green),
                    label: Text(
                      'Add Item',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      if (isAddingNew) return;

                      setState(() => isAddingNew = true);
                    },
                  ),
                ],
              ),
            )
          ],
        ),

        // gap between the above (header) widget and the list
        const SizedBox(height: 10.0),

        // items list
        // TODO: Make stats enum
        Expanded(
          child: ListView(
            children: <Widget>[
                  // only visible if new child is being added
                  if (isAddingNew)
                    EditingBulletTile(
                      item: _getNewEmptyItem(widget.poolType),
                      onDone: (item) {
                        widget.addToPool(item);
                        setState(() => isAddingNew = false);
                      },
                      onCancel: () => setState(() => isAddingNew = false),
                    ),
                ] +
                pool.map((e) {
                  if (e.id == editId) {
                    return EditingBulletTile(
                      item: e,
                      onDone: (item) {
                        widget.editPoolItem(item);
                        setState(() => editId = null);
                      },
                      onCancel: () => setState(() => editId = null),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: BulletEditTile(
                      label: e.label,
                      stats: hasStats ? e.stats : null,
                      onEditClicked: () {
                        if (editId != null) {
                          showDialog<String>(
                            context: context,
                            builder: (ctx) => Dialog(
                              backgroundColor: Colors.grey,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  'Editing progress...  Save them first.',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          );

                          return;
                        }

                        setState(() => editId = e.id);
                      },
                      onDeleteClicked: () {
                        // TODO: add a yes/no option
                        widget.deleteFromPool(e.id);
                        setState(() {/* Item from pool got removed */});
                      },
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}

dynamic _getNewEmptyItem(final PoolType poolType) {
  final genId = DateTime.now().millisecondsSinceEpoch;

  switch (poolType) {
    case PoolType.daily:
    case PoolType.weekly:
      return Task(id: genId, label: '', stats: const {});
    case PoolType.punishments:
      return Punishment(id: genId, label: '');
    case PoolType.rewards:
      return Reward(id: genId, label: '', rewardType: RewardType.noSideEffect);
  }
}
