library mnid_dart;

import 'dart:typed_data';

import 'package:base_x/base_x.dart';
import 'package:collection/collection.dart';
import 'package:hex/hex.dart';
import 'package:sha3/sha3.dart';

BaseXCodec base58 =
    BaseXCodec('123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz');
BaseXCodec hex = BaseXCodec('0123456789abcdef');

class MNID {
  static List<int> checksum(payload) {
    var k = SHA3(256, SHA3_PADDING, 256);
    k.update(payload);
    List<int> hash = k.digest();
    return hash.sublist(0, 4);
  }

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

  static bool isMNID(String encoded) {
    try {
      final Uint8List data = base58.decode(encoded);
      return data.length > 24 && data[0] == 1;
    } catch (e) {
      return false;
    }
  }
}
