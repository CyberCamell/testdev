class Term {
  final String term;
  final String description;
  final String link;

  Term({
    required this.term,
    required this.description,
    required this.link,
  });

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      term: json['term'] as String? ?? '',
      description: json['description'] as String? ?? '',
      link: json['link'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'term': term,
      'description': description,
      'link': link,
    };
  }
} 