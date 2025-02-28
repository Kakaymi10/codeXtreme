class ScanResult {
  final String id;
  final String name;
  final String type;
  final String date;
  final Map<String, dynamic> results;

  ScanResult({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.results,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      date: json['date'] ?? '',
      results: json['results'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'date': date,
      'results': results,
    };
  }
}
