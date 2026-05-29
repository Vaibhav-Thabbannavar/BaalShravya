class AwarenessContentModel {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String? createdAt;

  const AwarenessContentModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.createdAt,
  });

  factory AwarenessContentModel.fromJson(Map<String, dynamic> json) {
    return AwarenessContentModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}