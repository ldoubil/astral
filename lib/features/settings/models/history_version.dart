class HistoryVersion {
  final String version;
  final String url;
  final String date;

  HistoryVersion({
    required this.version,
    required this.url,
    required this.date,
  });

  factory HistoryVersion.fromJson(Map<String, dynamic> json) {
    return HistoryVersion(
      version: json['version'] as String,
      url: json['url'] as String,
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'version': version, 'url': url, 'date': date};
  }
}
