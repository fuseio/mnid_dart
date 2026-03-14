import 'package:mnid_dart/mnid_dart.dart';
import 'package:test/test.dart';

/// Test vectors: (network, address, encoded MNID).
const _vectors = <(String, String, String)>[
  (
    '0x1',
    '0x00521965e7bd230323c423d96c657db5b79d099f',
    '2nQtiQG6Cgm1GYTBaaKAgr76uY7iSexUkqX'
  ),
  (
    '0x94365e3a',
    '0x00521965e7bd230323c423d96c657db5b79d099f',
    '5A8bRWU3F7j3REx3vkJWxdjQPp4tqmxFPmab1Tr'
  ),
  (
    '0x3',
    '0x00521965e7bd230323c423d96c657db5b79d099f',
    '2oDZvNUgn77w2BKTkd9qKpMeUo8EL94QL5V'
  ),
  (
    '0x2a',
    '0x00521965e7bd230323c423d96c657db5b79d099f',
    '34ukSmiK1oA1C5Du8aWpkjFGALoH7nsHeDX'
  ),
  (
    '0x16b2',
    '0x00521965e7bd230323c423d96c657db5b79d099f',
    '9Xy8yQpdeCNSPGQ9jwTha9MRSb2QJ8HYzf1u'
  ),
];

const _vectorNames = [
  'main-net',
  'with genesis hash',
  'ropsten',
  'kovan',
  'infuranet',
];

void main() {
  group('encode', () {
    for (var i = 0; i < _vectors.length; i++) {
      final (network, address, encoded) = _vectors[i];
      test(_vectorNames[i], () {
        expect(
          MNID.encode(network: network, address: address),
          equals(encoded),
        );
      });
    }
  });

  group('decode', () {
    for (var i = 0; i < _vectors.length; i++) {
      final (network, address, encoded) = _vectors[i];
      test('${_vectorNames[i]} returns MnidResult with correct fields', () {
        final result = MNID.decode(encoded);
        expect(result, isA<MnidResult>());
        expect(result.network, equals(network));
        expect(result.address, equals(address));
      });
    }
  });

  group('isMNID', () {
    test('returns true for valid MNID', () {
      expect(MNID.isMNID('2nQtiQG6Cgm1GYTBaaKAgr76uY7iSexUkqX'), isTrue);
    });

    test('returns true for all test vectors', () {
      for (final (_, _, encoded) in _vectors) {
        expect(MNID.isMNID(encoded), isTrue);
      }
    });

    test('returns false for empty string', () {
      expect(MNID.isMNID(''), isFalse);
    });

    test('returns false for plain Ethereum address', () {
      expect(
        MNID.isMNID('0x00521965e7bd230323c423d96c657db5b79d099f'),
        isFalse,
      );
    });

    test('returns false for random string', () {
      expect(MNID.isMNID('helloWorld'), isFalse);
    });

    test('returns false for too-short base58 string', () {
      expect(MNID.isMNID('2nQti'), isFalse);
    });

    test('returns false for string with non-base58 chars (0, O, I, l)', () {
      expect(MNID.isMNID('0OIl'), isFalse);
    });
  });

  group('round-trip', () {
    for (var i = 0; i < _vectors.length; i++) {
      final (network, address, encoded) = _vectors[i];
      test('${_vectorNames[i]}: encode then decode', () {
        final encodedResult = MNID.encode(network: network, address: address);
        expect(encodedResult, equals(encoded));

        final decoded = MNID.decode(encodedResult);
        expect(decoded.network, equals(network));
        expect(decoded.address, equals(address));
      });

      test('${_vectorNames[i]}: decode then re-encode', () {
        final decoded = MNID.decode(encoded);
        final reEncoded = MNID.encode(
          network: decoded.network,
          address: decoded.address,
        );
        expect(reEncoded, equals(encoded));
      });
    }
  });

  group('error handling', () {
    test('decode throws MnidException for invalid checksum', () {
      // Take a valid MNID and corrupt the last character.
      const valid = '2nQtiQG6Cgm1GYTBaaKAgr76uY7iSexUkqX';
      final lastChar = valid[valid.length - 1];
      final corrupted =
          valid.substring(0, valid.length - 1) + (lastChar == 'a' ? 'b' : 'a');

      expect(
        () => MNID.decode(corrupted),
        throwsA(isA<MnidException>()),
      );
    });

    test('decode throws MnidException for empty string', () {
      expect(
        () => MNID.decode(''),
        throwsA(isA<MnidException>()),
      );
    });

    test('decode throws for too-short payload', () {
      expect(
        () => MNID.decode('2nQti'),
        throwsA(isA<MnidException>()),
      );
    });

    test('decode throws for non-base58 characters', () {
      expect(
        () => MNID.decode('0OIl+/='),
        throwsA(
          anyOf(
            isA<MnidException>(),
            isA<FormatException>(),
            isA<ArgumentError>(),
          ),
        ),
      );
    });

    test('MnidException.invalidChecksum has correct message', () {
      const ex = MnidException.invalidChecksum('test');
      expect(ex.message, equals('Invalid MNID checksum'));
      expect(ex.source, equals('test'));
    });

    test('MnidException.invalidVersion has correct message', () {
      const ex = MnidException.invalidVersion('test');
      expect(ex.message, equals('Invalid MNID version'));
    });

    test('MnidException.invalidPayload has correct message', () {
      const ex = MnidException.invalidPayload('test');
      expect(ex.message, equals('Invalid MNID payload'));
    });

    test('MnidException toString includes message', () {
      const ex = MnidException('Something went wrong');
      expect(ex.toString(), contains('Something went wrong'));
    });
  });

  group('MnidResult', () {
    test('equality works for identical values', () {
      const a = MnidResult(network: '0x1', address: '0xabc');
      const b = MnidResult(network: '0x1', address: '0xabc');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality for different network', () {
      const a = MnidResult(network: '0x1', address: '0xabc');
      const b = MnidResult(network: '0x3', address: '0xabc');
      expect(a, isNot(equals(b)));
    });

    test('inequality for different address', () {
      const a = MnidResult(network: '0x1', address: '0xabc');
      const b = MnidResult(network: '0x1', address: '0xdef');
      expect(a, isNot(equals(b)));
    });

    test('toMap returns correct keys', () {
      const r = MnidResult(network: '0x1', address: '0xabc');
      expect(r.toMap(), equals({'network': '0x1', 'address': '0xabc'}));
    });

    test('toString contains fields', () {
      const r = MnidResult(network: '0x1', address: '0xabc');
      expect(r.toString(), contains('0x1'));
      expect(r.toString(), contains('0xabc'));
    });
  });
}
