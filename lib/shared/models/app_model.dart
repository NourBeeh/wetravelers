/// Common baseline for all JSON-serialisable domain models.
///
/// [copyWith] is expected on concrete models; decoding failures return null so
/// callers can degrade gracefully instead of throwing mid-parse.
abstract interface class AppModel {
  Map<String, dynamic> toJson();

  /// Attempts to build this model from [json]; returns `null` on mismatch.
  factory AppModel.fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError('fromJson must be implemented by the model');
}