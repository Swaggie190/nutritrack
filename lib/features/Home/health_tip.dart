// This represents the Structure of a health Tip message
class HealthTip {
  final String message;
  final String category;
  final String? source;

  const HealthTip({
    required this.message,
    required this.category,
    this.source,
  });
}
