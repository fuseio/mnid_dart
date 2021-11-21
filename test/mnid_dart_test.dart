import "package:mnid_dart/mnid_dart.dart";
import "package:test/test.dart";

void main() {
  group("encode", () {
    test("main-net", () {
      expect(
        MNID.encode(
          network: '0x1',
          address: '0x00521965e7bd230323c423d96c657db5b79d099f',
        ),
        equals('2nQtiQG6Cgm1GYTBaaKAgr76uY7iSexUkqX'),
      );
    });

    test("with genesis hash", () {
      expect(
        MNID.encode(
          network: '0x94365e3a',
          address: '0x00521965e7bd230323c423d96c657db5b79d099f',
        ),
        equals('5A8bRWU3F7j3REx3vkJWxdjQPp4tqmxFPmab1Tr'),
      );
    });

    test("ropsten", () {
      expect(
        MNID.encode(
          network: '0x3',
          address: '0x00521965e7bd230323c423d96c657db5b79d099f',
        ),
        equals('2oDZvNUgn77w2BKTkd9qKpMeUo8EL94QL5V'),
      );
    });

    test("kovan", () {
      expect(
        MNID.encode(
          network: '0x2a',
          address: '0x00521965e7bd230323c423d96c657db5b79d099f',
        ),
        equals('34ukSmiK1oA1C5Du8aWpkjFGALoH7nsHeDX'),
      );
    });

    test("infuranet", () {
      expect(
        MNID.encode(
          network: '0x16b2',
          address: '0x00521965e7bd230323c423d96c657db5b79d099f',
        ),
        equals('9Xy8yQpdeCNSPGQ9jwTha9MRSb2QJ8HYzf1u'),
      );
    });
  });

  group("decode", () {
    test("main-net", () {
      expect(
        MNID.decode('2nQtiQG6Cgm1GYTBaaKAgr76uY7iSexUkqX'),
        equals({
          "network": '0x1',
          "address": '0x00521965e7bd230323c423d96c657db5b79d099f'
        }),
      );
    });

    test("with genesis hash", () {
      expect(
        MNID.decode('5A8bRWU3F7j3REx3vkJWxdjQPp4tqmxFPmab1Tr'),
        equals(
          {
            "network": '0x94365e3a',
            "address": '0x00521965e7bd230323c423d96c657db5b79d099f'
          },
        ),
      );
    });

    test("ropsten", () {
      expect(
        MNID.decode('2oDZvNUgn77w2BKTkd9qKpMeUo8EL94QL5V'),
        equals(
          {
            "network": '0x3',
            "address": '0x00521965e7bd230323c423d96c657db5b79d099f'
          },
        ),
      );
    });

    test("kovan", () {
      expect(
        MNID.decode('34ukSmiK1oA1C5Du8aWpkjFGALoH7nsHeDX'),
        equals(
          {
            "network": '0x2a',
            "address": '0x00521965e7bd230323c423d96c657db5b79d099f'
          },
        ),
      );
    });
  });

  group("isMNID", () {
    test("is valid", () {
      expect(
        MNID.isMNID('2nQtiQG6Cgm1GYTBaaKAgr76uY7iSexUkqX'),
        isTrue,
      );
    });
  });
}
