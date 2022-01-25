import 'package:flutter_test/flutter_test.dart';
import 'package:messagepack/messagepack.dart';

void main() {
  const List<int> testMessage = [147, 2, 166, 114, 101, 100, 114, 97, 119, 220, 0, 33, 220, 0, 17, 170, 111, 112, 116, 105, 111, 110, 95, 115, 101, 116, 146, 171, 97, 114, 97, 98, 105, 99, 115, 104, 97, 112, 101, 195, 146, 169, 97, 109, 98, 105, 119, 105, 100, 116, 104, 166, 115, 105, 110, 103, 108, 101, 146, 165, 101, 109, 111, 106, 105, 195, 146, 167, 103, 117, 105, 102, 111, 110, 116, 160, 146, 171, 103, 117, 105, 102, 111, 110, 116, 119, 105, 100, 101, 160, 146, 169, 108, 105, 110, 101, 115, 112, 97, 99, 101, 0, 146, 170, 109, 111, 117, 115, 101, 102, 111, 99, 117, 115, 194, 146, 168, 112, 117, 109, 98, 108, 101, 110, 100, 0, 146, 171, 115, 104, 111, 119, 116, 97, 98, 108, 105, 110, 101, 1, 146, 173, 116, 101, 114, 109, 103, 117, 105, 99, 111, 108, 111, 114, 115, 194, 146, 168, 116, 116, 105, 109, 101, 111, 117, 116, 195, 146, 171, 116, 116, 105, 109, 101, 111, 117, 116, 108, 101, 110, 50, 146, 172, 101, 120, 116, 95, 108, 105, 110, 101, 103, 114, 105, 100, 194, 146, 173, 101, 120, 116, 95, 109, 117, 108, 116, 105, 103, 114, 105, 100, 194, 146, 171, 101, 120, 116, 95, 104, 108, 115, 116, 97, 116, 101, 194, 146, 174, 101, 120, 116, 95, 116, 101, 114, 109, 99, 111, 108, 111, 114, 115, 194, 146, 178, 100, 101, 102, 97, 117, 108, 116, 95, 99, 111, 108, 111, 114, 115, 95, 115, 101, 116, 149, 206, 0, 255, 255, 255, 0, 206, 0, 255, 0, 0, 0, 0, 146, 169, 117, 112, 100, 97, 116, 101, 95, 102, 103, 145, 206, 0, 255, 255, 255, 146, 169, 117, 112, 100, 97, 116, 101, 95, 98, 103, 145, 0, 146, 169, 117, 112, 100, 97, 116, 101, 95, 115, 112, 145, 206, 0, 255, 0, 0, 220, 0, 52, 172, 104, 108, 95, 103, 114, 111, 117, 112, 95, 115, 101, 116, 146, 170, 83, 112, 101, 99, 105, 97, 108, 75, 101, 121, 1, 146, 171, 69, 110, 100, 79, 102, 66, 117, 102, 102, 101, 114, 1, 146, 170, 84, 101, 114, 109, 67, 117, 114, 115, 111, 114, 1, 146, 172, 84, 101, 114, 109, 67, 117, 114, 115, 111, 114, 78, 67, 1, 146, 167, 78, 111, 110, 84, 101, 120, 116, 1, 146, 169, 68, 105, 114, 101, 99, 116, 111, 114, 121, 1, 146, 168, 69, 114, 114, 111, 114, 77, 115, 103, 1, 146, 169, 73, 110, 99, 83, 101, 97, 114, 99, 104, 1, 146, 166, 83, 101, 97, 114, 99, 104, 1, 146, 167, 77, 111, 114, 101, 77, 115, 103, 1, 146, 167, 77, 111, 100, 101, 77, 115, 103, 1, 146, 166, 76, 105, 110, 101, 78, 114, 1, 146, 172, 67, 117, 114, 115, 111, 114, 76, 105, 110, 101, 78, 114, 1, 146, 168, 81, 117, 101, 115, 116, 105, 111, 110, 1, 146, 170, 83, 116, 97, 116, 117, 115, 76, 105, 110, 101, 1, 146, 172, 83, 116, 97, 116, 117, 115, 76, 105, 110, 101, 78, 67, 1, 146, 169, 86, 101, 114, 116, 83, 112, 108, 105, 116, 1, 146, 165, 84, 105, 116, 108, 101, 1, 146, 166, 86, 105, 115, 117, 97, 108, 1, 146, 168, 86, 105, 115, 117, 97, 108, 78, 67, 1, 146, 170, 87, 97, 114, 110, 105, 110, 103, 77, 115, 103, 1, 146, 168, 87, 105, 108, 100, 77, 101, 110, 117, 1, 146, 166, 70, 111, 108, 100, 101, 100, 1, 146, 170, 70, 111, 108, 100, 67, 111, 108, 117, 109, 110, 1, 146, 167, 68, 105, 102, 102, 65, 100, 100, 1, 146, 170, 68, 105, 102, 102, 67, 104, 97, 110, 103, 101, 1, 146, 170, 68, 105, 102, 102, 68, 101, 108, 101, 116, 101, 1, 146, 168, 68, 105, 102, 102, 84, 101, 120, 116, 1, 146, 170, 83, 105, 103, 110, 67, 111, 108, 117, 109, 110, 1, 146, 167, 67, 111, 110, 99, 101, 97, 108, 1, 146, 168, 83, 112, 101, 108, 108, 66, 97, 100, 1, 146, 168, 83, 112, 101, 108, 108, 67, 97, 112, 1, 146, 169, 83, 112, 101, 108, 108, 82, 97, 114, 101, 1, 146, 170, 83, 112, 101, 108, 108, 76, 111, 99, 97, 108, 1, 146, 165, 80, 109, 101, 110, 117, 1, 146, 168, 80, 109, 101, 110, 117, 83, 101, 108, 1, 146, 169, 80, 109, 101, 110, 117, 83, 98, 97, 114, 1, 146, 170, 80, 109, 101, 110, 117, 84, 104, 117, 109, 98, 1, 146, 167, 84, 97, 98, 76, 105, 110, 101, 1, 146, 170, 84, 97, 98, 76, 105, 110, 101, 83, 101, 108, 1, 146, 171, 84, 97, 98, 76, 105, 110, 101, 70, 105, 108, 108, 1, 146, 172, 67, 117, 114, 115, 111, 114, 67, 111, 108, 117, 109, 110, 1, 146, 170, 67, 117, 114, 115, 111, 114, 76, 105, 110, 101, 1, 146, 171, 67, 111, 108, 111, 114, 67, 111, 108, 117, 109, 110, 1, 146, 172, 81, 117, 105, 99, 107, 70, 105, 120, 76, 105, 110, 101, 1, 146, 170, 87, 104, 105, 116, 101, 115, 112, 97, 99, 101, 1, 146, 168, 78, 111, 114, 109, 97, 108, 78, 67, 0, 146, 172, 77, 115, 103, 83, 101, 112, 97, 114, 97, 116, 111, 114, 1, 146, 171, 78, 111, 114, 109, 97, 108, 70, 108, 111, 97, 116, 1, 146, 167, 77, 115, 103, 65, 114, 101, 97, 1, 146, 171, 70, 108, 111, 97, 116, 66, 111, 114, 100, 101, 114, 1, 150, 170, 111, 112, 116, 105, 111, 110, 95, 115, 101, 116, 146, 171, 101, 120, 116, 95, 99, 109, 100, 108, 105, 110, 101, 194, 146, 173, 101, 120, 116, 95, 112, 111, 112, 117, 112, 109, 101, 110, 117, 194, 146, 171, 101, 120, 116, 95, 116, 97, 98, 108, 105, 110, 101, 194, 146, 172, 101, 120, 116, 95, 119, 105, 108, 100, 109, 101, 110, 117, 194, 146, 172, 101, 120, 116, 95, 109, 101, 115, 115, 97, 103, 101, 115, 194, 146, 178, 100, 101, 102, 97, 117, 108, 116, 95, 99, 111, 108, 111, 114, 115, 95, 115, 101, 116, 149, 206, 0, 255, 255, 255, 0, 206, 0, 255, 0, 0, 0, 0, 146, 169, 117, 112, 100, 97, 116, 101, 95, 102, 103, 145, 206, 0, 255, 255, 255, 146, 169, 117, 112, 100, 97, 116, 101, 95, 98, 103, 145, 0, 146, 169, 117, 112, 100, 97, 116, 101, 95, 115, 112, 145, 206, 0, 255, 0, 0, 146, 166, 114, 101, 115, 105, 122, 101, 146, 12, 5, 146, 165, 99, 108, 101, 97, 114, 144, 146, 171, 99, 117, 114, 115, 111, 114, 95, 103, 111, 116, 111, 146, 4, 0, 146, 173, 104, 105, 103, 104, 108, 105, 103, 104, 116, 95, 115, 101, 116, 145, 128, 157, 163, 112, 117, 116, 145, 161, 121, 145, 161, 111, 145, 161, 108, 145, 161, 111, 145, 161, 32, 145, 161, 100, 145, 161, 97, 145, 161, 119, 145, 161, 103, 145, 161, 33, 145, 161, 32, 145, 161, 32, 146, 172, 119, 105, 110, 95, 118, 105, 101, 119, 112, 111, 114, 116, 150, 2, 199, 3, 1, 205, 3, 232, 0, 1, 0, 0, 146, 177, 115, 101, 116, 95, 115, 99, 114, 111, 108, 108, 95, 114, 101, 103, 105, 111, 110, 148, 0, 4, 0, 11, 146, 166, 115, 99, 114, 111, 108, 108, 145, 4, 146, 177, 115, 101, 116, 95, 115, 99, 114, 111, 108, 108, 95, 114, 101, 103, 105, 111, 110, 148, 0, 4, 0, 4, 146, 171, 99, 117, 114, 115, 111, 114, 95, 103, 111, 116, 111, 146, 1, 0, 157, 163, 112, 117, 116, 145, 161, 80, 145, 161, 114, 145, 161, 101, 145, 161, 115, 145, 161, 115, 145, 161, 32, 145, 161, 69, 145, 161, 78, 145, 161, 84, 145, 161, 69, 145, 161, 82, 145, 161, 32, 146, 171, 99, 117, 114, 115, 111, 114, 95, 103, 111, 116, 111, 146, 2, 0, 157, 163, 112, 117, 116, 145, 161, 111, 145, 161, 114, 145, 161, 32, 145, 161, 116, 145, 161, 121, 145, 161, 112, 145, 161, 101, 145, 161, 32, 145, 161, 99, 145, 161, 111, 145, 161, 109, 145, 161, 109, 146, 171, 99, 117, 114, 115, 111, 114, 95, 103, 111, 116, 111, 146, 3, 0, 157, 163, 112, 117, 116, 145, 161, 97, 145, 161, 110, 145, 161, 100, 145, 161, 32, 145, 161, 116, 145, 161, 111, 145, 161, 32, 145, 161, 99, 145, 161, 111, 145, 161, 110, 145, 161, 116, 145, 161, 105, 146, 171, 99, 117, 114, 115, 111, 114, 95, 103, 111, 116, 111, 146, 4, 0, 157, 163, 112, 117, 116, 145, 161, 110, 145, 161, 117, 145, 161, 101, 145, 161, 32, 145, 161, 32, 145, 161, 32, 145, 161, 32, 145, 161, 32, 145, 161, 32, 145, 161, 32, 145, 161, 32, 145, 161, 32, 146, 171, 99, 117, 114, 115, 111, 114, 95, 103, 111, 116, 111, 146, 4, 3, 146, 173, 109, 111, 100, 101, 95, 105, 110, 102, 111, 95, 115, 101, 116, 146, 195, 220, 0, 17, 140, 171, 109, 111, 117, 115, 101, 95, 115, 104, 97, 112, 101, 0, 172, 99, 117, 114, 115, 111, 114, 95, 115, 104, 97, 112, 101, 165, 98, 108, 111, 99, 107, 175, 99, 101, 108, 108, 95, 112, 101, 114, 99, 101, 110, 116, 97, 103, 101, 0, 169, 98, 108, 105, 110, 107, 119, 97, 105, 116, 0, 167, 98, 108, 105, 110, 107, 111, 110, 0, 168, 98, 108, 105, 110, 107, 111, 102, 102, 0, 165, 104, 108, 95, 105, 100, 0, 165, 105, 100, 95, 108, 109, 0, 167, 97, 116, 116, 114, 95, 105, 100, 0, 170, 97, 116, 116, 114, 95, 105, 100, 95, 108, 109, 0, 164, 110, 97, 109, 101, 166, 110, 111, 114, 109, 97, 108, 170, 115, 104, 111, 114, 116, 95, 110, 97, 109, 101, 161, 110, 140, 171, 109, 111, 117, 115, 101, 95, 115, 104, 97, 112, 101, 0, 172, 99, 117, 114, 115, 111, 114, 95, 115, 104, 97, 112, 101, 165, 98, 108, 111, 99, 107, 175, 99, 101, 108, 108, 95, 112, 101, 114, 99, 101, 110, 116, 97, 103, 101, 0, 169, 98, 108, 105, 110, 107, 119, 97, 105, 116, 0, 167, 98, 108, 105, 110, 107, 111, 110, 0, 168, 98, 108, 105, 110, 107, 111, 102, 102, 0, 165, 104, 108, 95, 105, 100, 0, 165, 105, 100, 95, 108, 109, 0, 167, 97, 116, 116, 114, 95, 105, 100, 0, 170, 97, 116, 116, 114, 95, 105, 100, 95, 108, 109, 0, 164, 110, 97, 109, 101, 166, 118, 105, 115, 117, 97, 108, 170, 115, 104, 111, 114, 116, 95, 110, 97, 109, 101, 161, 118, 140, 171, 109, 111, 117, 115, 101, 95, 115, 104, 97, 112, 101, 0, 172, 99, 117, 114, 115, 111, 114, 95, 115, 104, 97, 112, 101, 168, 118, 101, 114, 116, 105, 99, 97, 108, 175, 99, 101, 108, 108, 95, 112, 101, 114, 99, 101, 110, 116, 97, 103, 101, 25, 169, 98, 108, 105, 110, 107, 119, 97, 105, 116, 0, 167, 98, 108, 105, 110, 107, 111, 110, 0, 168, 98, 108, 105, 110, 107, 111, 102, 102, 0, 165, 104, 108, 95, 105, 100, 0, 165, 105, 100, 95, 108, 109, 0, 167, 97, 116, 116, 114, 95, 105, 100, 0, 170, 97, 116, 116, 114, 95, 105, 100, 95, 108, 109, 0, 164, 110, 97, 109, 101, 166, 105, 110, 115, 101, 114, 116, 170, 115, 104, 111, 114, 116, 95, 110, 97, 109, 101, 161, 105, 140, 171, 109, 111, 117, 115, 101, 95, 115, 104, 97, 112, 101, 0, 172, 99, 117, 114, 115, 111, 114, 95, 115, 104, 97, 112, 101, 170, 104, 111, 114, 105, 122, 111, 110, 116, 97, 108, 175, 99, 101, 108, 108, 95, 112, 101, 114, 99, 101, 110, 116, 97, 103, 101, 20, 169, 98, 108, 105, 110, 107, 119, 97, 105, 116, 0, 167, 98, 108, 105, 110, 107, 111, 110, 0, 168, 98, 108, 105, 110, 107, 111, 102, 102, 0, 165, 104, 108, 95, 105, 100, 0, 165, 105, 100, 95, 108, 109, 0, 167, 97, 116, 116, 114, 95, 105, 100, 0, 170, 97, 116, 116, 114, 95, 105, 100, 95, 108, 109, 0, 164, 110, 97, 109, 101, 167, 114, 101, 112, 108, 97, 99, 101, 170, 115, 104, 111, 114, 116, 95, 110, 97, 109, 101, 161, 114, 140, 171, 109, 111, 117, 115, 101, 95, 115, 104, 97, 112, 101, 0, 172, 99, 117, 114, 115, 111, 114, 95, 115, 104, 97, 112, 101, 165, 98, 108, 111, 99, 107, 175, 99, 101, 108, 108, 95, 112, 101, 114, 99, 101, 110, 116, 97, 103, 101, 0, 169, 98, 108, 105, 110, 107, 119, 97, 105, 116, 0, 167, 98, 108, 105, 110, 107, 111, 110, 0, 168, 98, 108, 105, 110, 107, 111, 102, 102, 0, 165, 104, 108, 95, 105, 100, 0, 165, 105, 100, 95, 108, 109, 0, 167, 97, 116, 116, 114, 95, 105, 100, 0, 170, 97, 116, 116, 114, 95, 105, 100, 95, 108, 109, 0, 164, 110, 97, 109, 101, 174, 99, 109, 100, 108, 105, 110, 101, 95, 110, 111, 114, 109, 97, 108, 170, 115, 104, 111, 114, 116, 95, 110, 97, 109, 101, 161, 99, 140, 171, 109, 111, 117, 115, 101, 95, 115, 104, 97, 112, 101, 0, 172, 99, 117, 114, 115, 111, 114, 95, 115, 104, 97, 112, 101, 168, 118, 101, 114, 116, 105, 99, 97, 108, 175, 99, 101, 108, 108, 95, 112, 101, 114, 99, 101, 110, 116, 97, 103, 101, 25, 169, 98, 108, 105, 110, 107, 119, 97, 105, 116, 0, 167, 98, 108, 105, 110, 107, 111, 110, 0, 168, 98, 108, 105, 110, 107, 111, 102, 102, 0, 165, 104, 108, 95, 105, 100, 0, 165, 105, 100, 95, 108, 109, 0, 167, 97, 116, 116, 114, 95, 105, 100, 0, 170, 97, 116, 116, 114, 95, 105, 100, 95, 108, 109, 0, 164, 110, 97, 109, 101, 174, 99, 109, 100, 108, 105, 110, 101, 95, 105, 110, 115, 101, 114, 116, 170, 115, 104, 111, 114, 116, 95, 110, 97, 109, 101, 162, 99, 105, 140, 171, 109, 111, 117, 115, 101, 95, 115, 104, 97, 112, 101, 0, 172, 99, 117, 114, 115, 111, 114, 95, 115, 104, 97, 112, 101, 170, 104, 111, 114, 105, 122, 111, 110, 116, 97, 108, 175, 99, 101, 108, 108, 95, 112, 101, 114, 99, 101, 110, 116, 97, 103, 101, 20, 169, 98, 108, 105, 110, 107, 119, 97, 105, 116, 0, 167, 98, 108, 105, 110, 107, 111, 110, 0, 168, 98, 108, 105, 110, 107, 111, 102, 102, 0, 165, 104, 108, 95, 105, 100, 0, 165, 105, 100, 95, 108, 109, 0, 167, 97, 116, 116, 114, 95, 105, 100, 0, 170, 97, 116, 116, 114, 95, 105, 100, 95, 108, 109, 0, 164, 110, 97, 109, 101, 175, 99, 109, 100, 108, 105, 110, 101, 95, 114, 101, 112, 108, 97, 99, 101, 170, 115, 104, 111, 114, 116, 95, 110, 97, 109, 101, 162, 99, 114, 140, 171, 109, 111, 117, 115, 101, 95, 115, 104, 97, 112, 101, 0, 172, 99, 117, 114, 115, 111, 114, 95, 115, 104, 97, 112, 101, 170, 104, 111, 114, 105, 122, 111, 110, 116, 97, 108, 175, 99, 101, 108, 108, 95, 112, 101, 114, 99, 101, 110, 116, 97, 103, 101, 20, 169, 98, 108, 105, 110, 107, 119, 97, 105, 116, 0, 167, 98, 108, 105, 110, 107, 111, 110, 0, 168, 98, 108, 105, 110, 107, 111, 102, 102, 0, 165, 104, 108, 95, 105, 100, 0, 165, 105, 100, 95, 108, 109, 0, 167, 97, 116, 116, 114, 95, 105, 100, 0, 170, 97, 116, 116, 114, 95, 105, 100, 95, 108, 109, 0, 164, 110, 97, 109, 101, 168, 111, 112, 101, 114, 97, 116, 111, 114, 170, 115, 104, 111, 114, 116, 95, 110, 97, 109, 101, 161, 111, 140, 171, 109, 111, 117, 115, 101, 95, 115, 104, 97, 112, 101, 0, 172, 99, 117, 114, 115, 111, 114, 95, 115, 104, 97, 112, 101, 168, 118, 101, 114, 116, 105, 99, 97, 108, 175, 99, 101, 108, 108, 95, 112, 101, 114, 99, 101, 110, 116, 97, 103, 101, 25, 169, 98, 108, 105, 110, 107, 119, 97, 105, 116, 0, 167, 98, 108, 105, 110, 107, 111, 110, 0, 168, 98, 108, 105, 110, 107, 111, 102, 102, 0, 165, 104, 108, 95, 105, 100, 0, 165, 105, 100, 95, 108, 109, 0, 167, 97, 116, 116, 114, 95, 105, 100, 0, 170, 97, 116, 116, 114, 95, 105, 100, 95, 108, 109, 0, 164, 110, 97, 109, 101, 173, 118, 105, 115, 117, 97, 108, 95, 115, 101, 108, 101, 99, 116, 170, 115, 104, 111, 114, 116, 95, 110, 97, 109, 101, 162, 118, 101, 131, 171, 109, 111, 117, 115, 101, 95, 115, 104, 97, 112, 101, 0, 164, 110, 97, 109, 101, 173, 99, 109, 100, 108, 105, 110, 101, 95, 104, 111, 118, 101, 114, 170, 115, 104, 111, 114, 116, 95, 110, 97, 109, 101, 161, 101, 131, 171, 109, 111, 117, 115, 101, 95, 115, 104, 97, 112, 101, 0, 164, 110, 97, 109, 101, 176, 115, 116, 97, 116, 117, 115, 108, 105, 110, 101, 95, 104, 111, 118, 101, 114, 170, 115, 104, 111, 114, 116, 95, 110, 97, 109, 101, 161, 115, 131, 171, 109, 111, 117, 115, 101, 95, 115, 104, 97, 112, 101, 0, 164, 110, 97, 109, 101, 175, 115, 116, 97, 116, 117, 115, 108, 105, 110, 101, 95, 100, 114, 97, 103, 170, 115, 104, 111, 114, 116, 95, 110, 97, 109, 101, 162, 115, 100, 131, 171, 109, 111, 117, 115, 101, 95, 115, 104, 97, 112, 101, 0, 164, 110, 97, 109, 101, 170, 118, 115, 101, 112, 95, 104, 111, 118, 101, 114, 170, 115, 104, 111, 114, 116, 95, 110, 97, 109, 101, 162, 118, 115, 131, 171, 109, 111, 117, 115, 101, 95, 115, 104, 97, 112, 101, 0, 164, 110, 97, 109, 101, 169, 118, 115, 101, 112, 95, 100, 114, 97, 103, 170, 115, 104, 111, 114, 116, 95, 110, 97, 109, 101, 162, 118, 100, 131, 171, 109, 111, 117, 115, 101, 95, 115, 104, 97, 112, 101, 0, 164, 110, 97, 109, 101, 164, 109, 111, 114, 101, 170, 115, 104, 111, 114, 116, 95, 110, 97, 109, 101, 161, 109, 131, 171, 109, 111, 117, 115, 101, 95, 115, 104, 97, 112, 101, 0, 164, 110, 97, 109, 101, 173, 109, 111, 114, 101, 95, 108, 97, 115, 116, 108, 105, 110, 101, 170, 115, 104, 111, 114, 116, 95, 110, 97, 109, 101, 162, 109, 108, 139, 172, 99, 117, 114, 115, 111, 114, 95, 115, 104, 97, 112, 101, 165, 98, 108, 111, 99, 107, 175, 99, 101, 108, 108, 95, 112, 101, 114, 99, 101, 110, 116, 97, 103, 101, 0, 169, 98, 108, 105, 110, 107, 119, 97, 105, 116, 0, 167, 98, 108, 105, 110, 107, 111, 110, 0, 168, 98, 108, 105, 110, 107, 111, 102, 102, 0, 165, 104, 108, 95, 105, 100, 0, 165, 105, 100, 95, 108, 109, 0, 167, 97, 116, 116, 114, 95, 105, 100, 0, 170, 97, 116, 116, 114, 95, 105, 100, 95, 108, 109, 0, 164, 110, 97, 109, 101, 169, 115, 104, 111, 119, 109, 97, 116, 99, 104, 170, 115, 104, 111, 114, 116, 95, 110, 97, 109, 101, 162, 115, 109, 146, 171, 109, 111, 100, 101, 95, 99, 104, 97, 110, 103, 101, 146, 166, 110, 111, 114, 109, 97, 108, 0, 146, 169, 109, 111, 117, 115, 101, 95, 111, 102, 102, 144, 146, 165, 102, 108, 117, 115, 104, 144];

  test('foo', () {
    final Unpacker unpacker = Unpacker.fromList(testMessage);
    final listLength = unpacker.unpackListLength();
    expect(listLength, 3); // This is notification?
    final type = unpacker.unpackInt();
    expect(type, 2); // notification
    final method = unpacker.unpackString();
    expect(method, 'redraw');
    // for redraw, the 
    final paramLength = unpacker.unpackListLength();
    expect(paramLength, 33); // ?
    var unpackedLists = <List>[];
    for (var i = 0; i < 33; i += 1) {
      try {
        unpackedLists.add(unpacker.unpackList());
      } on FormatException {
        print(unpackedLists);
        fail('i = $i');
      }
    }
  });
}
