class ScanResult {
  final String id;
  final String name;
  final String type;
  final String date;
  final Map<String, dynamic> results;
  // You're missing this property but trying to set it
  final String? result;

  ScanResult({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.results,
    this.result, // Make it optional with no 'required' keyword
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      date: json['date'] ?? '',
      results: json['results'] ?? {},
      result: json['result'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'date': date,
      'results': results,
      'result': result,
    };
  }
}
