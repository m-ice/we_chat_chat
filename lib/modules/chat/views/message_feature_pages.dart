import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_refresh_view.dart';
import '../../../domain/entities/message_center_item.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/message_center_repository.dart';
import '../controllers/message_center_controller.dart';
import 'widgets/chat_visuals.dart';

enum MessageContactPageKind { relationship, visitors, calls }

class SystemMessagesPage extends StatelessWidget {
  const SystemMessagesPage({
    super.key,
    required this.repository,
    required this.assistant,
    this.onOpenChat,
  });

  final MessageCenterRepository repository;
  final User? assistant;
  final VoidCallback? onOpenChat;

  @override
  Widget build(BuildContext context) {
    return _MessageFeatureScaffold(
      title: '系统消息',
      section: MessageCenterSection.system,
      repository: repository,
      bodyBuilder: (_, controller) {
        final notices = controller.systemNotices;
        if (notices.isEmpty) return const _EmptyFeatureState();
        return ListView.builder(
          key: const ValueKey('system-message-list'),
          padding: const EdgeInsets.fromLTRB(16, 3, 16, 24),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: notices.length,
          itemBuilder: (context, index) {
            final notice = notices[index];
            return Align(
              alignment: Alignment.topLeft,
              child: InkWell(
                key: ValueKey('system-notice-${notice.id}'),
                onTap: onOpenChat,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChatAvatar(assetPath: notice.avatarPath, size: 40),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 240),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          notice.content,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MessageContactPage extends StatelessWidget {
  const MessageContactPage({
    super.key,
    required this.title,
    required this.kind,
    required this.repository,
    required this.onOpenChat,
    this.onCall,
  });

  final String title;
  final MessageContactPageKind kind;
  final MessageCenterRepository repository;
  final ValueChanged<User> onOpenChat;
  final ValueChanged<User>? onCall;

  MessageCenterSection get _section => switch (kind) {
    MessageContactPageKind.relationship => MessageCenterSection.relationships,
    MessageContactPageKind.visitors => MessageCenterSection.visitors,
    MessageContactPageKind.calls => MessageCenterSection.calls,
  };

  @override
  Widget build(BuildContext context) {
    return _MessageFeatureScaffold(
      title: title,
      section: _section,
      repository: repository,
      bodyBuilder: (_, controller) => switch (kind) {
        MessageContactPageKind.relationship => _RelationshipList(
          controller: controller,
          onOpenChat: onOpenChat,
        ),
        MessageContactPageKind.visitors => _VisitorList(
          records: controller.visitors,
          onOpenChat: onOpenChat,
        ),
        MessageContactPageKind.calls => _CallList(
          controller: controller,
          onOpenChat: onOpenChat,
          onCall: onCall,
        ),
      },
    );
  }
}

class _RelationshipList extends StatelessWidget {
  const _RelationshipList({required this.controller, required this.onOpenChat});

  final MessageCenterController controller;
  final ValueChanged<User> onOpenChat;

  @override
  Widget build(BuildContext context) {
    final relationships = controller.relationships
        .where((item) => item.state != RelationshipState.removed)
        .toList(growable: false);
    if (relationships.isEmpty) return const _EmptyFeatureState();
    return ListView.builder(
      key: const ValueKey('relationship-list'),
      padding: const EdgeInsets.only(top: 3, bottom: 24),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: relationships.length,
      itemBuilder: (context, index) {
        final relationship = relationships[index];
        return _ContactRow(
          key: ValueKey('relationship-${relationship.person.id}'),
          person: relationship.person,
          onTap: () => onOpenChat(_toUser(relationship.person)),
          onLongPress: () => _confirmRemove(context, relationship),
        );
      },
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    IntimateRelationship relationship,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('解除亲密关系'),
        content: Text('确定解除与${relationship.person.nickname}的亲密关系吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('解除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.removeRelationship(relationship);
    }
  }
}

class _VisitorList extends StatelessWidget {
  const _VisitorList({required this.records, required this.onOpenChat});

  final List<VisitorRecord> records;
  final ValueChanged<User> onOpenChat;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) return const _EmptyFeatureState();
    return ListView.builder(
      key: const ValueKey('visitor-list'),
      padding: const EdgeInsets.only(top: 3, bottom: 24),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _ContactRow(
          key: ValueKey('visitor-${record.person.id}'),
          person: record.person,
          onTap: () => onOpenChat(_toUser(record.person)),
        );
      },
    );
  }
}

class _CallList extends StatelessWidget {
  const _CallList({
    required this.controller,
    required this.onOpenChat,
    required this.onCall,
  });

  final MessageCenterController controller;
  final ValueChanged<User> onOpenChat;
  final ValueChanged<User>? onCall;

  @override
  Widget build(BuildContext context) {
    final records = controller.calls;
    if (records.isEmpty) return const _EmptyFeatureState();
    return ListView.builder(
      key: const ValueKey('call-record-list'),
      padding: const EdgeInsets.only(top: 3, bottom: 24),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _ContactRow(
          key: ValueKey('call-${record.id}'),
          person: record.person,
          onTap: () => onOpenChat(_toUser(record.person)),
          onLongPress: onCall == null ? null : () => _callback(record.person),
        );
      },
    );
  }

  Future<void> _callback(MessageCenterPerson person) async {
    final record = await controller.addDemoCallback(person);
    if (record != null) onCall?.call(_toUser(person));
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    super.key,
    required this.person,
    required this.onTap,
    this.onLongPress,
  });

  final MessageCenterPerson person;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        height: 72,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ChatAvatar(assetPath: person.avatarPath, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  person.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
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

typedef _MessageBodyBuilder =
    Widget Function(BuildContext context, MessageCenterController controller);

class _MessageFeatureScaffold extends StatefulWidget {
  const _MessageFeatureScaffold({
    required this.title,
    required this.section,
    required this.repository,
    required this.bodyBuilder,
  });

  final String title;
  final MessageCenterSection section;
  final MessageCenterRepository repository;
  final _MessageBodyBuilder bodyBuilder;

  @override
  State<_MessageFeatureScaffold> createState() =>
      _MessageFeatureScaffoldState();
}

class _MessageFeatureScaffoldState extends State<_MessageFeatureScaffold> {
  late final String _controllerTag;
  late final MessageCenterController _controller;

  @override
  void initState() {
    super.initState();
    _controllerTag =
        'message-center-${widget.section.name}-${identityHashCode(this)}';
    _controller = Get.put(
      MessageCenterController(widget.repository, widget.section),
      tag: _controllerTag,
    );
  }

  @override
  void dispose() {
    Get.delete<MessageCenterController>(tag: _controllerTag, force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const ChatHeaderBackdrop(height: 255),
          SafeArea(
            child: Column(
              children: [
                ChatPageBar(title: widget.title),
                Expanded(
                  child: Obx(() {
                    if (_controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentYellow,
                        ),
                      );
                    }
                    if (_controller.hasError.value) {
                      return Center(
                        child: TextButton.icon(
                          onPressed: _controller.load,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('加载失败，点击重试'),
                        ),
                      );
                    }
                    return AppRefreshView(
                      onRefresh: _controller.load,
                      child: widget.bodyBuilder(context, _controller),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFeatureState extends StatelessWidget {
  const _EmptyFeatureState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * .55,
          child: const Center(
            child: Text(
              '暂时没有新消息',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

User _toUser(MessageCenterPerson person) => User(
  id: person.id,
  nickname: person.nickname,
  age: 0,
  gender: '',
  hobbies: const [],
  avatarPath: person.avatarPath,
  intro: '',
  isVerified: false,
);
