import 'dart:typed_data';

import './constants.dart';

/// Format characters (similar to Python struct module):
///   @  native endian, native size
///   =  native endian, standard size
///   <  little-endian
///   >  big-endian
///   !  network (= big-endian)
///   x  pad byte
///   b  signed char (1 byte)
///   B  unsigned char (1 byte)
///   ?  boolean (1 byte)
///   h  signed short (2 bytes)
///   H  unsigned short (2 bytes)
///   i  signed int (4 bytes)
///   I  unsigned int (4 bytes)
///   l  signed long (8 bytes)
///   L  unsigned long (8 bytes)
///   f  float (4 bytes)
///   d  double (8 bytes)

List<Object> unpack(String format, ByteBuffer buffer) {
  if (format.isEmpty) {
    throw ArgumentError('Format string must have a value');
  }

  final length = calculateSize(format);

  if (length != buffer.lengthInBytes) {
    throw FormatException(
      'Format string length does not match buffer length',
    );
  }

  final output = <Object>[];
  final bytes = ByteData.view(buffer);

  Endian endian = Endian.host;
  int i = 0;

  final firstChar = format[0];
  if (firstChar == '@' || firstChar == '=') {
    endian = Endian.host;
    i = 1;
  } else if (firstChar == '<') {
    endian = Endian.little;
    i = 1;
  } else if (firstChar == '>' || firstChar == '!') {
    endian = Endian.big;
    i = 1;
  }

  int index = 0;

  for (; i < format.length; i++) {
    final ch = format[i];

    switch (ch) {
      case 'x':
        index += 1;
      case 'b':
        output.add(bytes.getInt8(index));
        index += 1;
      case 'B':
        output.add(bytes.getUint8(index));
        index += 1;
      case '?':
        output.add(bytes.getUint8(index) != 0);
        index += 1;
      case 'h':
        output.add(bytes.getInt16(index, endian));
        index += 2;
      case 'H':
        output.add(bytes.getUint16(index, endian));
        index += 2;
      case 'i':
        output.add(bytes.getInt32(index, endian));
        index += 4;
      case 'I':
        output.add(bytes.getUint32(index, endian));
        index += 4;
      case 'l':
        output.add(bytes.getInt64(index, endian));
        index += 8;
      case 'L':
        output.add(bytes.getUint64(index, endian));
        index += 8;
      case 'f':
        output.add(bytes.getFloat32(index, endian));
        index += 4;
      case 'd':
        output.add(bytes.getFloat64(index, endian));
        index += 8;
      default:
        throw FormatException("Format string cannot contain '$ch'");
    }
  }

  return output;
}

ByteBuffer pack(String format, List<Object> data) {
  if (format.isEmpty) {
    throw ArgumentError('Format string must have a value');
  }

  final length = calculateSize(format);

  int dataIndex = 0;
  final bytes = ByteData(length);

  Endian endian = Endian.host;
  int i = 0;
  final firstChar = format[0];
  if (firstChar == '@' || firstChar == '=') {
    endian = Endian.host;
    i = 1;
  } else if (firstChar == '<') {
    endian = Endian.little;
    i = 1;
  } else if (firstChar == '>' || firstChar == '!') {
    endian = Endian.big;
    i = 1;
  }

  int index = 0;

  for (; i < format.length; i++) {
    final ch = format[i];
    switch (ch) {
      case 'x':
        index += 1;
      case 'b':
        int byte = data[dataIndex++] as int;
        byte = byte.clamp(signedByteMin, signedByteMax);
        bytes.setInt8(index, byte);
        index += 1;
      case 'B':
        int byte = data[dataIndex++] as int;
        byte = byte.clamp(unsignedByteMin, unsignedByteMax);
        bytes.setUint8(index, byte);
        index += 1;
      case '?':
        final boolVal = data[dataIndex++] as bool;
        bytes.setUint8(index, boolVal ? 1 : 0);
        index += 1;
      case 'h':
        int short = data[dataIndex++] as int;
        short = short.clamp(signedShortMin, signedShortMax);
        bytes.setInt16(index, short, endian);
        index += 2;
      case 'H':
        int short = data[dataIndex++] as int;
        short = short.clamp(unsignedShortMin, unsignedShortMax);
        bytes.setUint16(index, short, endian);
        index += 2;
      case 'i':
        int integer = data[dataIndex++] as int;
        integer = integer.clamp(signedIntMin, signedIntMax);
        bytes.setInt32(index, integer, endian);
        index += 4;
      case 'I':
        int integer = data[dataIndex++] as int;
        integer = integer.clamp(unsignedIntMin, unsignedIntMax);
        bytes.setUint32(index, integer, endian);
        index += 4;
      case 'l':
        int long = data[dataIndex++] as int;
        long = long.clamp(signedLongMin, signedLongMax);
        bytes.setInt64(index, long, endian);
        index += 8;
      case 'L':
        int long = data[dataIndex++] as int;
        long = long.clamp(unsignedLongMin, unsignedLongMax);
        bytes.setUint64(index, long, endian);
        index += 8;
      case 'f':
        final float = data[dataIndex++] as double;
        bytes.setFloat32(index, float, endian);
        index += 4;
      case 'd':
        final doubleVal = data[dataIndex++] as double;
        bytes.setFloat64(index, doubleVal, endian);
        index += 8;
      default:
        throw FormatException("Format string cannot contain '$ch'");
    }
  }

  return bytes.buffer;
}

int calculateSize(String format) {
  if (format.isEmpty) {
    throw ArgumentError('Format string must have a value');
  }

  int calculatedSize = 0;
  for (int i = 0; i < format.length; i++) {
    final ch = format[i];
    switch (ch) {
      case '@':
      case '=':
      case '<':
      case '!':
      case '>':
        break;
      case 'x':
      case 'b':
      case 'B':
      case '?':
        calculatedSize += 1;
      case 'h':
      case 'H':
        calculatedSize += 2;
      case 'i':
      case 'I':
      case 'f':
        calculatedSize += 4;
      case 'l':
      case 'L':
      case 'd':
        calculatedSize += 8;
      default:
        throw FormatException("Format string cannot contain '$ch'");
    }
  }

  return calculatedSize;
}
