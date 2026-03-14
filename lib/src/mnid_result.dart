/// The result of decoding an MNID string.
///
/// Contains the [network] identifier and the [address] extracted
/// from the encoded MNID.
class MnidResult {
  /// The network identifier as a hex string (e.g., '0x1' for mainnet).
  final String network;

  /// The Ethereum address as a hex string (e.g., '0x00521965...').
  final String address;

  /// Creates an [MnidResult] with the given [network] and [address].
  const MnidResult({
    required this.network,
    required this.address,
  });

  /// Converts this result to a [Map] for backward compatibility.
  ///
  /// Returns a map with 'network' and 'address' keys.
  Map<String, String> toMap() {
    return {
      'network': network,
      'address': address,
    };
  }

  @override
  String toString() => 'MnidResult(network: $network, address: $address)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MnidResult &&
          runtimeType == other.runtimeType &&
          network == other.network &&
          address == other.address;

  @override
  int get hashCode => network.hashCode ^ address.hashCode;
}
