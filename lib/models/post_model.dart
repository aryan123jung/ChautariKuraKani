class PostModel {
  final String profileUrl; 
  final String name;
  final String hoursAgo;
  final String caption;
  final String? imageUrl;
  final bool isPoll; 

  PostModel({
    required this.profileUrl,
    required this.name,
    required this.hoursAgo,
    required this.caption,
    this.imageUrl,
    this.isPoll = false,
  });
}
