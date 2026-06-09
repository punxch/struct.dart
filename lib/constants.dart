const int signedByteMin = -128;
const int signedByteMax = 127;

const int unsignedByteMin = 0;
const int unsignedByteMax = 255;

const int signedShortMin = -32768;
const int signedShortMax = 32767;

const int unsignedShortMin = 0;
const int unsignedShortMax = 65535;

const int signedIntMin = -2147483648;
const int signedIntMax = 2147483647;

const int unsignedIntMin = 0;
const int unsignedIntMax = 4294967295;

const int signedLongMin = -9223372036854775808;
const int signedLongMax = 9223372036854775807;

const int unsignedLongMin = 0;
// unsignedLongMax (2^64 - 1) exceeds Dart's 64-bit signed int range.
// Use clamp with signedLongMax as practical upper bound for Dart.
const int unsignedLongMax = 9223372036854775807;
