bool hasSameStickerOrder(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (int index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

bool hasSameStickerSet(List<String> left, List<String> right) {
  return left.length == right.length && left.toSet().containsAll(right);
}
