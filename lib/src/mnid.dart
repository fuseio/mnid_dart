import 'dart:typed_data';

import 'package:base_x/base_x.dart';
import 'package:collection/collection.dart';
import 'package:hex/hex.dart';
import 'package:sha3/sha3.dart';

import 'mnid_exception.dart';
import 'mnid_result.dart';

/// The Base58 encoding codec used for MNID encoding.
final BaseXCodec _base58 =
    BaseXCodec('123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz');

/// The hexadecimal encoding codec (lowercase).
final BaseXCodec _hex = BaseXCodec('0123456789abcdef');

/// Multi Network Identifier (MNID) Dart implementation.
///
/// Provides encoding and decoding of Ethereum addresses combined with a
/// network identifier, useful for handling addresses across different
/// networks (e.g., mainnet, testnets) in a unified format.
///
/// See the [MNID specification](https://github.com/uport-project/mnid)
/// for details on the encoding format.
class MNID {
  /// Calculates the checksum of the given [payload].
  ///
  /// Returns the first 4 bytes of the SHA3-256 hash of [payload].
  static Uint8List checksum(Uint8List payload) {
    final SHA3 hasher = SHA3(256, SHA3_PADDING, 256);
    hasher.update(payload);
    final List<int> hash = hasher.digest();
    return Uint8List.fromList(hash.sublist(0, 4));
  }

  /// Encodes an Ethereum [address] and [network] identifier into an MNID string.
  ///
  /// Both [network] and [address] should be hex strings prefixed with '0x'.
  ///
  /// Example:
  /// ```dart
  /// final mnid = MNID.encode(
  ///   network: '0x1',
  ///   address: '0x00521965e7bd230323c423d96c657db5b79d099f',
  /// );
  /// ```
  static String encode({
    required String network,
    required String address,
  }) {
    final Uint8List version = Uint8List.fromList(HEX.decode('01'));
    final Uint8List networkBytes =
        Uint8List.fromList(_hex.decode(network.substring(2)));
    final Uint8List addressBytes =
        Uint8List.fromList(HEX.decode(address.substring(2)));

    final Uint8List payloadWithoutChecksum = Uint8List.fromList(
      <int>[...version, ...networkBytes, ...addressBytes],
    );
    final Uint8List check = checksum(payloadWithoutChecksum);

    return _base58.encode(
      Uint8List.fromList(
        <int>[...payloadWithoutChecksum, ...check],
      ),
    );
  }

  /// Decodes an MNID [encoded] string into an [MnidResult].
  ///
  /// Returns an [MnidResult] containing the network identifier and
  /// Ethereum address.
  ///
  /// Throws [MnidException.invalidPayload] if the payload is too short.
  /// Throws [MnidException.invalidVersion] if the version byte is not 1.
  /// Throws [MnidException.invalidChecksum] if the checksum does not match.
  ///
  /// Example:
  /// ```dart
  /// final result = MNID.decode('2odZJFePBbdo2Lang2MVqBY1kFRvaE');
  /// print(result.network);  // '0x1'
  /// print(result.address);  // '0x00521965e7bd230323c423d96c657db5b79d099f'
  /// ```
  static MnidResult decode(String encoded) {
    final Uint8List data = _base58.decode(encoded);

    if (data.length <= 24) {
      throw MnidException.invalidPayload(encoded);
    }

    final int netLength = data.length - 24;
    final Uint8List version = Uint8List.sublistView(data, 0, 1);
    final Uint8List network = Uint8List.sublistView(data, 1, netLength);
    final Uint8List address =
        Uint8List.sublistView(data, netLength, 20 + netLength);
    final Uint8List check = Uint8List.sublistView(data, netLength + 20);

    if (version[0] != 1) {
      throw MnidException.invalidVersion(encoded);
    }

    final Uint8List flat = Uint8List.fromList(
      <int>[...version, ...network, ...address],
    );

    if (!check.equals(checksum(flat))) {
      throw MnidException.invalidChecksum(encoded);
    }

    return MnidResult(
      network: '0x${_hex.encode(network)}',
      address: '0x${HEX.encode(address)}',
    );
  }

  /// Returns whether the given [encoded] string is a valid MNID.
  ///
  /// Returns `true` if [encoded] can be base58-decoded and has a valid
  /// length and version byte; `false` otherwise.
  static bool isMNID(String encoded) {
    try {
      final Uint8List data = _base58.decode(encoded);
      return data.length > 24 && data[0] == 1;
    } catch (e) {
      return false;
    }
  }
}
