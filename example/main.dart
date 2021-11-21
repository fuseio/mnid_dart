import 'dart:convert';
import 'dart:io';

import 'package:mnid_dart/mnid_dart.dart';

void main() {
  print('enter mnid hash and press ENTER');
  String? mnidAddress =
      stdin.readLineSync(encoding: Encoding.getByName('utf-8')!);
  if (mnidAddress == null) {
    print('enter mnid hash and press ENTER');
    mnidAddress = stdin.readLineSync(encoding: Encoding.getByName('utf-8')!);
  }
  print('isMNID ${MNID.isMNID(mnidAddress!)}');

  final en = MNID.encode(
    network: '0x1',
    address: '0x00521965e7bd230323c423d96c657db5b79d099f',
  );
  print('encode $en');

  print('encode toEqual:  ${en == '2nQtiQG6Cgm1GYTBaaKAgr76uY7iSexUkqX'}');

  final decoderrrr = MNID.decode('34ukSmiK1oA1C5Du8aWpkjFGALoH7nsHeDX');
  print('decoderrrr ${decoderrrr.toString()}');
}
