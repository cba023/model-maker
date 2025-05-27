class Collectiontool {
  static bool areSetsEqual(Set<dynamic> set1, Set<dynamic> set2) {
    if (identical(set1, set2)) return true;
    return set1.length == set2.length && set1.containsAll(set2);
  }
}
