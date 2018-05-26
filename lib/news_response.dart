class Source {
  final String id;
  final String name;

  Source({this.id, this.name});

  factory Source.fromJson(Map<String, dynamic> json) {
    return new Source(
      id: json['id'],
      name: json['name']
    );
  }
}

class NewsItem {
  final Source source;
  final String author;
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;

  NewsItem({this.source, this.author, this.title, this.description, this.url, this.urlToImage, this.publishedAt});

  factory NewsItem.fromJson(dynamic json) {
    return NewsItem(
      source: Source.fromJson(json['source']),
      author: json['author'],
      title: json['title'],
      description: json['description'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt']
    );
  }
}

class NewsSource {
  final String status;
  final int totalResults;
  final List<dynamic> articles;

  NewsSource({this.status, this.totalResults, this.articles});

  factory NewsSource.fromJson(Map<String, dynamic> json) {
    return NewsSource(
      status: json['status'],
      totalResults: json['totalResults'],
      articles: (json['articles'] as List).map((article) => new NewsItem.fromJson(article)).toList()
    );
  }
}