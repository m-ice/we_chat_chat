/// Result of attempting to add the current local user to one activity.
///
/// Activity membership is keyed by activity id, never by the organizer id, so
/// two activities created by the same person remain independent.
enum TeamActivityJoinResult { joined, alreadyJoined, full, unavailable }
