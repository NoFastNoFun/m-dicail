abstract final class TranscriptMergeHelper {
  static String merge(String base, String segment) {
    if (base.isEmpty) {
      return segment;
    }
    if (segment.isEmpty) {
      return base;
    }
    if (segment.startsWith(base)) {
      return segment;
    }
    if (base.endsWith(segment)) {
      return base;
    }

    final maxOverlap =
        base.length < segment.length ? base.length : segment.length;
    for (var overlap = maxOverlap; overlap > 0; overlap--) {
      if (base.endsWith(segment.substring(0, overlap))) {
        return base + segment.substring(overlap);
      }
    }

    return '$base $segment';
  }
}
