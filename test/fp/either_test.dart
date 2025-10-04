import 'package:aad_oauth/fp/either.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Either factories', () {
    test('of should create a Right', () {
      final either = Either.of(1);
      expect(either, Right<String, int>(1));
    });
    test('left should create a Left', () {
      final either = Either.left('error');
      expect(either, Left<String, int>('error'));
    });
    test('right should create a Right', () {
      final either = Either.right(1);
      expect(either, Right<String, int>(1));
    });
  });

  group('Either methods', () {
    test('Right.map should apply the function to the value', () {
      final either = Right<String, int>(1);
      final mapped = either.map((value) => value * 2);
      expect(mapped, Right<String, int>(2));
    });
    test('Left.map should return the same Left', () {
      final either = Left<String, int>('error');
      final mapped = either.map((value) => value * 2);
      expect(mapped, Left<String, int>('error'));
    });
    test('Right.mapLeft should return the same Right', () {
      final either = Right<String, int>(1);
      final mapped = either.mapLeft((value) => value * 2);
      expect(mapped, Right<String, int>(1));
    });
    test('Left.mapLeft should apply the function to the value', () {
      final either = Left<String, int>('error');
      final mapped = either.mapLeft((value) => 'this is an $value');
      expect(mapped, Left<String, int>('this is an error'));
    });
    test('Right.flatMap should apply the function to the value', () {
      final either = Right<String, int>(1);
      final flatMapped = either.flatMap((value) => Right<String, int>(value * 2));
      expect(flatMapped, Right<String, int>(2));
    });
    test('Left.flatMap should return the same Left', () {
      final either = Left<String, int>('error');
      final flatMapped = either.flatMap((value) => Right<String, int>(value * 2));
      expect(flatMapped, Left<String, int>('error'));
    });
    test('Right.fold should apply the function to the value', () {
      final either = Right<String, int>(1);
      final folded = either.fold((left) => left, (right) => right * 2);
      expect(folded, 2);
    });
    test('Left.fold should apply the function to the value', () {
      final either = Left<String, int>('error');
      final folded = either.fold((left) => left, (right) => right * 2);
      expect(folded, 'error');
    });
  });
}
