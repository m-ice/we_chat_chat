import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'team_publish_controller.dart';

const _activityYellow = Color(0xFFFFCE45);

class TeamActivityPickerPage extends StatelessWidget {
  const TeamActivityPickerPage({super.key, this.initialValue});

  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: TeamActivityPickerSheet(initialValue: initialValue),
      ),
    );
  }
}

class TeamActivityPickerSheet extends StatefulWidget {
  const TeamActivityPickerSheet({super.key, this.initialValue});

  final String? initialValue;

  @override
  State<TeamActivityPickerSheet> createState() =>
      _TeamActivityPickerSheetState();
}

class _TeamActivityPickerSheetState extends State<TeamActivityPickerSheet> {
  String? selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        key: const ValueKey('team-activity-picker-sheet'),
        height: 448,
        width: MediaQuery.sizeOf(context).width,
        child: Padding(
          padding: EdgeInsets.fromLTRB(18, 12, 16, 12 + safeBottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PickerHeader(
                selectedCount: selected == null ? 0 : 1,
                onClose: () => Navigator.pop(context),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: TeamPublishController.activityGroups.entries
                        .map(
                          (entry) => _ActivityGroup(
                            title: entry.key,
                            items: entry.value,
                            selected: selected,
                            onSelected: (value) =>
                                setState(() => selected = value),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  key: const ValueKey('team-activity-confirm'),
                  onPressed: selected == null
                      ? null
                      : () => Navigator.pop(context, selected),
                  style: FilledButton.styleFrom(
                    backgroundColor: _activityYellow,
                    disabledBackgroundColor: const Color(0xFFFFE69C),
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'common_confirm'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerHeader extends StatelessWidget {
  const _PickerHeader({required this.selectedCount, required this.onClose});

  final int selectedCount;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: Row(
        children: [
          const SizedBox(width: 32),
          Expanded(
            child: Text(
              'team_type_count'.trParams({'count': '$selectedCount'}),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp,color: Colors.black),
            ),
          ),
          IconButton(
            key: const ValueKey('team-activity-close'),
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 18),
            style: IconButton.styleFrom(
              minimumSize: const Size.square(28),
              maximumSize: const Size.square(28),
              padding: EdgeInsets.zero,
              backgroundColor: const Color(0xFFF4F4F4),
              foregroundColor: const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityGroup extends StatelessWidget {
  const _ActivityGroup({
    required this.title,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> items;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 9, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.tr,
            style: const TextStyle(color: Color(0xFF333333), fontSize: 14),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (item) => _ActivityChip(
                    label: item,
                    selected: selected == item,
                    onTap: () => onSelected(item),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _ActivityChip extends StatelessWidget {
  const _ActivityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _activityYellow : const Color(0xFFF4F4F4),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        key: ValueKey('team-activity-$label'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text(
            label.tr,
            style: const TextStyle(color: Color(0xFF333333), fontSize: 14),
          ),
        ),
      ),
    );
  }
}
