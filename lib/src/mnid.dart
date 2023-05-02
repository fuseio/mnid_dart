library mnid_dart;

import 'dart:typed_data';

import 'package:base_x/base_x.dart';
import 'package:collection/collection.dart';
import 'package:hex/hex.dart';
import 'package:sha3/sha3.dart';

/// The Base58 encoding codec used for MNID encoding.
BaseXCodec base58 =
    BaseXCodec('123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz');

/// The hexadecimal encoding codec.
BaseXCodec hex = BaseXCodec('0123456789abcdef');

/// Multi Network Identifier (MNID) Dart implementation.
///
/// This library provides a way to encode and decode Ethereum addresses
/// with a network identifier, useful for handling addresses from different
/// networks (e.g., mainnet, testnets) in a unified way.
class MNID {
  /// Calculates the checksum of the given payload using the first 4 bytes
  /// of its SHA3-256 hash.
  ///
  /// [payload] - A list of integers representing the payload to be hashed.
  static List<int> checksum(payload) {
    var k = SHA3(256, SHA3_PADDING, 256);
    k.update(payload);
    List<int> hash = k.digest();
    return hash.sublist(0, 4);
  }

  /// Encodes the given Ethereum address and network identifier into an MNID.
  ///
  /// [network] - The network identifier as a hexadecimal string.
  /// [address] - The Ethereum address as a hexadecimal string.
  static String encode({
    required String network,
    required String address,
  }) {
    final List<List<int>> payload = [
      HEX.decode('01'),
      hex.decode(network.substring(2)),
      HEX.decode(address.substring(2)),
    ];
    final List<int> flat = Uint8List.fromList(
      payload.expand((element) => element).toList(),
    );
    payload.add(checksum(flat));

    return base58.encode(
      Uint8List.fromList(
        payload.expand((element) => element).toList(),
      ),
    );
  }

  /// Decodes an MNID string into its corresponding network identifier and
  /// Ethereum address.
  ///
  /// [encoded] - The MNID string to be decoded.
  /// Returns a Map with 'network' and 'address' keys.
  /// Throws an exception if the address checksum is invalid.
  static Map decode(String encoded) {
    final Uint8List data = base58.decode(encoded);
    final netLength = data.length - 24;
    final version = data.sublist(0, 1);
    final network = data.sublist(1, netLength);
    final address = data.sublist(netLength, 20 + netLength);
    final check = data.sublist(netLength + 20);
    final List<int> flat = Uint8List.fromList(
      [version, network, address].expand((element) => element).toList(),
    );
    if (check.equals(checksum(flat))) {
      return {
        "network": '0x${hex.encode(network)}',
        "address": '0x${HEX.encode(address)}'
      };
    } else {
      throw Exception('Invalid address checksum');
    }
  }

  /// Determines whether the given string is a valid MNID.
  ///
  /// [encoded] - The string to be checked.
  /// Returns true if the input is a valid MNID, false otherwise.
  static bool isMNID(String encoded) {
    try {
      final Uint8List data = base58.decode(encoded);
      return data.length > 24 && data[0] == 1;
    } catch (e) {
      return false;
    }
  }
}
