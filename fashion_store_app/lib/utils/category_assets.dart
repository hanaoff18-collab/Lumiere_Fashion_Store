/// Maps Firestore category names to bundled hero images (mens / womens / kids / sports).
String? categoryHeroAsset(String category) {
  final c = category.toLowerCase().trim();
  if (c.contains('sport')) return 'assets/categories/cat_sports.png';
  if (c.contains('baby') || c.contains('kid')) return 'assets/categories/cat_kids.png';
  if (c.contains('women') || c.contains('woman') || c.contains('womans')) {
    return 'assets/categories/cat_women.png';
  }
  if (c.contains('men') && !c.contains('women')) {
    return 'assets/categories/cat_men.png';
  }
  return null;
}
