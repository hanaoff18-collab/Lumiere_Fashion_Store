class PromoBanner {
  const PromoBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.buttonText = 'Shop now',
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String buttonText;

  factory PromoBanner.fromMap(String id, Map<String, dynamic> data) {
    return PromoBanner(
      id: id,
      title: (data['title'] ?? '').toString(),
      subtitle: (data['subtitle'] ?? '').toString(),
      imageUrl: (data['imageUrl'] ?? '').toString(),
      buttonText: (data['buttonText'] ?? 'Shop now').toString(),
    );
  }
}
