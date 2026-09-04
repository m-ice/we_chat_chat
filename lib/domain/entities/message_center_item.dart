enum RelationshipState { intimate, pending, removed }

enum CallDirection { incoming, outgoing }

enum CallState { completed, missed, cancelled, demo }

class MessageCenterPerson {
  const MessageCenterPerson({
    required this.id,
    required this.nickname,
    required this.avatarPath,
  });

  final int id;
  final String nickname;
  final String avatarPath;
}

class SystemNotice {
  const SystemNotice({
    required this.id,
    required this.content,
    required this.avatarPath,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String content;
  final String avatarPath;
  final DateTime createdAt;
  final bool isRead;

  SystemNotice copyWith({bool? isRead}) => SystemNotice(
    id: id,
    content: content,
    avatarPath: avatarPath,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
  );
}

class IntimateRelationship {
  const IntimateRelationship({
    required this.person,
    required this.state,
    required this.since,
    this.unreadCount = 0,
  });

  final MessageCenterPerson person;
  final RelationshipState state;
  final DateTime since;
  final int unreadCount;

  IntimateRelationship copyWith({RelationshipState? state, int? unreadCount}) =>
      IntimateRelationship(
        person: person,
        state: state ?? this.state,
        since: since,
        unreadCount: unreadCount ?? this.unreadCount,
      );
}

class VisitorRecord {
  const VisitorRecord({
    required this.person,
    required this.visitedAt,
    this.isRead = false,
  });

  final MessageCenterPerson person;
  final DateTime visitedAt;
  final bool isRead;

  VisitorRecord copyWith({bool? isRead}) => VisitorRecord(
    person: person,
    visitedAt: visitedAt,
    isRead: isRead ?? this.isRead,
  );
}

class CallRecord {
  const CallRecord({
    required this.id,
    required this.person,
    required this.direction,
    required this.state,
    required this.happenedAt,
    required this.durationSeconds,
    this.isRead = false,
  });

  final String id;
  final MessageCenterPerson person;
  final CallDirection direction;
  final CallState state;
  final DateTime happenedAt;
  final int durationSeconds;
  final bool isRead;

  CallRecord copyWith({bool? isRead}) => CallRecord(
    id: id,
    person: person,
    direction: direction,
    state: state,
    happenedAt: happenedAt,
    durationSeconds: durationSeconds,
    isRead: isRead ?? this.isRead,
  );
}
