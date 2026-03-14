/// Exception thrown when MNID encoding or decoding fails.
///
/// Extends [FormatException] to provide specific error information
/// about what went wrong during MNID processing.
class MnidException extends FormatException {
  /// Creates an [MnidException] with the given [message] and optional [source].
  const MnidException(super.message, [Object? super.source]);

  /// Creates an [MnidException] for an invalid checksum.
  const MnidException.invalidChecksum([Object? source])
      : super('Invalid MNID checksum', source);

  /// Creates an [MnidException] for an invalid version byte.
  const MnidException.invalidVersion([Object? source])
      : super('Invalid MNID version', source);

  /// Creates an [MnidException] for an invalid payload length or content.
  const MnidException.invalidPayload([Object? source])
      : super('Invalid MNID payload', source);

  @override
  String toString() => 'MnidException: $message';
}
