part of graphview;

class BuchheimWalkerConfiguration {
  int siblingSeparation = DEFAULT_SIBLING_SEPARATION;
  int houseHoldSeparation = DEFAULT_SIBLING_SEPARATION;
  int levelSeparation = DEFAULT_LEVEL_SEPARATION;
  int subtreeSeparation = DEFAULT_SUBTREE_SEPARATION;
  int orientation = DEFAULT_ORIENTATION;
  static const ORIENTATION_TOP_BOTTOM = 1;
  static const DEFAULT_SIBLING_SEPARATION = 100;
  static const DEFAULT_HOUSEHOLD_SEPARATION = 200;
  static const DEFAULT_SUBTREE_SEPARATION = 100;
  static const DEFAULT_LEVEL_SEPARATION = 100;
  static const DEFAULT_ORIENTATION = 1;

  int getSiblingSeparation() {
    return siblingSeparation;
  }

  int getLevelSeparation() {
    return levelSeparation;
  }

  int getSubtreeSeparation() {
    return subtreeSeparation;
  }
}
