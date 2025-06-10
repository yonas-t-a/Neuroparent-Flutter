class Article {
  final int? articleId;
  final String articleTitle;
  final String articleContent;
  final String articleCategory;
  final String articleImage;
  final int? articleCreatorId;

  Article({
    this.articleId,
    required this.articleTitle,
    required this.articleContent,
    required this.articleCategory,
    required this.articleImage,
    this.articleCreatorId,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      articleId: json['article_id'],
      articleTitle: json['article_title'],
      articleContent: json['article_content'],
      articleCategory: json['article_category'],
      articleImage: json['article_image'],
      articleCreatorId: json['article_creator_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': articleTitle,
      'content': articleContent,
      'category': articleCategory,
      // 'img': articleImage, // For multipart, handled separately
    };
  }
}
