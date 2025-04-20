import 'package:flutter/material.dart';
import 'package:lvl_up/core/modals.dart';

import 'stat_count.dart';

final class BulletCheckTile extends StatelessWidget {
  const BulletCheckTile({
    super.key,
    required this.label,
    required this.isDone,
    required this.onDone,
    this.stats,
  });

  final String label;
  final bool isDone;
  final void Function() onDone;
  final Map? stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• '),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label),
                    Text(
                      stats?.toString() ?? '',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Checkbox.adaptive(
          side: BorderSide.none,
          fillColor: WidgetStateProperty.resolveWith<Color>(
            (_) => Colors.green.shade300,
          ),
          value: isDone,
          onChanged: (_) => onDone(), // TODO: onDone with no bool passed is bad
        ),
      ],
    );
  }
}

final class BulletEditTile extends StatelessWidget {
  const BulletEditTile({
    super.key,
    required this.label,
    this.stats,
    required this.onEditClicked,
    required this.onDeleteClicked,
  });

  final String label;
  final Map? stats;
  final void Function() onEditClicked;
  final void Function() onDeleteClicked;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• '),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label),
                    if (stats != null)
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: StatCount(statMap: stats as Map<String, int>),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        IconButton(onPressed: onEditClicked, icon: Icon(Icons.edit)),
        const SizedBox(width: 30.0),
        IconButton(onPressed: onDeleteClicked, icon: Icon(Icons.delete)),
      ],
    );
  }
}

final class EditingBulletTile extends StatefulWidget {
  const EditingBulletTile({
    super.key,
    required this.item,
    required this.onDone,
    required this.onCancel,
  });

  final dynamic item;
  final void Function(dynamic item) onDone;
  final void Function() onCancel;

  @override
  State<EditingBulletTile> createState() => _EditingBulletTileState();
}

final class _EditingBulletTileState extends State<EditingBulletTile> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    _focusNode = FocusNode();
    // WARNING: widget.item is dynamic
    _textController = TextEditingController(text: widget.item.label);
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats =
        widget.item is Task ? widget.item.stats?.toString() ?? '' : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• '),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      onTapOutside: (_) => _focusNode.unfocus(),
                    ),
                    if (stats != '')
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: StatCount(statMap: widget.item.stats),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => widget.onDone(
            widget.item.copyWith(label: _textController.text),
          ),
          icon: Icon(Icons.check),
          color: Colors.green,
        ),
        const SizedBox(width: 30.0),
        IconButton(
          onPressed: () => widget.onCancel(),
          icon: Icon(Icons.close_rounded),
          color: Colors.red,
        ),
      ],
    );
  }
}
