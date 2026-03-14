# Multi Network Identifier (MNID)

MNID is translated from https://github.com/uport-project/mnid

## Installation

Add `mnid_dart` to your `pubspec.yaml`:

```yaml
dependencies:
  mnid_dart: ^0.2.0
```

Then run:

```bash
dart pub get
```

## Basics

Ethereum, and uPort, is entering a multi-chain world. As end users increasingly interact with multiple chains, on Ethereum or elsewhere, the risk of users/servers inadvertently transferring value from an address on network X to an address on network Y is growing. This could result in monetary loss. Since uPort is switching to a new test network, we need to solve this issue urgently.

The Bitcoin protocol uses [Base58Check encoding](https://en.bitcoin.it/wiki/Base58Check_encoding) to prevent users from sending value off-network, but the ethereum ecosystem has used a raw hex version of the address instead.

## Extendible Encoding

My proposal is inspired by the Base58Check encoding as well as [EIP77](https://github.com/ethereum/EIPs/issues/77) but also specifies a network identifier, which allows us to programmatically extract the network used by an address as well as provide a visual indicator of the network used.

The following items are encoded:

* 1 byte version number currently `1`
* network id or four bytes of genesis block hash (or both)
* actual address data
* Four bytes (32 bits) of SHA3-based error checking code (digest of the version, network and payload)

Then base58 encoding is applied to the end result. The end result is fairly complete but still extendible in the future. We could start by simply using the network id and replace it with the genesis block hash and other meta data in the future.

### Benefits

This works with ethereum blockchains, but can easily be extended to other blockchains or even non-blockchain identifiers in the future. It would also be straightforward to add further details specifying which fork etc.

### Examples

The following Ethereum hex encoded address `0x00521965e7bd230323c423d96c657db5b79d099f` could be encoded as follows

* main-net: `2nQtiQG6Cgm1GYTBaaKAgr76uY7iSexUkqX`
* ropsten: `2oDZvNUgn77w2BKTkd9qKpMeUo8EL94QL5V`
* kovan: `34ukSmiK1oA1C5Du8aWpkjFGALoH7nsHeDX`
* infuranet: `9Xy8yQpdeCNSPGQ9jwTha9MRSb2QJ8HYzf1u`

## Usage

```dart
import 'package:mnid_dart/mnid_dart.dart';

// Encode an address with a network identifier
final encoded = MNID.encode(
  network: '0x1',
  address: '0x00521965e7bd230323c423d96c657db5b79d099f',
);
print(encoded); // '2nQtiQG6Cgm1GYTBaaKAgr76uY7iSexUkqX'

// Decode an MNID string into a typed result
final result = MNID.decode('2nQtiQG6Cgm1GYTBaaKAgr76uY7iSexUkqX');
print(result.network); // '0x1'
print(result.address); // '0x00521965e7bd230323c423d96c657db5b79d099f'

// Check if a string is a valid MNID
print(MNID.isMNID('2nQtiQG6Cgm1GYTBaaKAgr76uY7iSexUkqX')); // true
print(MNID.isMNID('0x00521965e7bd230323c423d96c657db5b79d099f')); // false
```

## Error Handling

`decode()` throws `MnidException` (a subclass of `FormatException`) when the input is invalid:

```dart
import 'package:mnid_dart/mnid_dart.dart';

try {
  final result = MNID.decode(someString);
  print('Network: ${result.network}, Address: ${result.address}');
} on MnidException catch (e) {
  print('Failed to decode MNID: $e');
}
```

`MnidException` provides named constructors for specific error types:

- `MnidException.invalidChecksum` -- the checksum does not match
- `MnidException.invalidVersion` -- the version byte is not supported
- `MnidException.invalidPayload` -- the payload is too short or malformed

## Inspirations

### Base58Check Encoding

Bitcoin's encoding consists of the following 3 items:

* Version prefix - Used more as a type and network field. See [list](https://en.bitcoin.it/wiki/List_of_address_prefixes).
* Payload (eg. hash of public key)
* Four bytes (32 bits) of SHA256-based error checking code (digest of the version and payload)

The whole thing is base58 encoded for compactness and URL safety.

The version prefix allows humans to visually recognize the address type from the first few characters in the string. The error checking code ensures that there aren't any obvious errors in the address.

### EIP77

A previous attempt at solving this for ethereum is found in [EIP 77](https://github.com/ethereum/EIPs/issues/77) which is similar to Base58Check:

* 1 flag byte - currently undefined. I suppose this could be used to pick a chain. But 1 byte does not seem enough
* Payload (eg. hash of public key)
* Four bytes (32 bits) of  SHA3-based error error checking code (digest of the version and payload)
