/// A minimal replacement for the [Either] class from the [dartz](https://pub.dev/packages/dartz) package.
///
///
sealed class Either<L, R> {
  const Either._();

  /// Creates a pure  [Either] instance.
  factory Either.of(R value) => Right<L, R>(value);

  /// Creates a [Left] instance.
  factory Either.left(L value) => Left<L, R>(value);

  /// Creates a [Right] instance.
  factory Either.right(R value) => Right<L, R>(value);

  /// Fold an [Either] (Left or Right) into a single value.
  ///
  /// ```dart
  /// final either = Right(1);
  /// final folded = either.fold((left) => left, (right) => right * 2);
  /// expect(folded, 2);
  /// ```
  T fold<T>(T Function(L) left, T Function(R) right) {
    return switch (this) {
      Left(:final value) => left(value),
      Right(:final value) => right(value),
    };
  }

  /// Maps a [Right] value to a new value.
  ///
  /// If the [Either] is a [Left], it returns the same [Left].
  ///
  /// ```dart
  /// final either = Right(1);
  /// final mapped = either.map((value) => value * 2);
  /// expect(mapped, Right(2));
  /// ```
  Either<L, T> map<T>(T Function(R) f);

  /// Maps a [Left] value to a new value.
  ///
  /// If the [Either] is a [Right], it returns the same [Right].
  ///
  /// ```dart
  /// final either = Left('error');
  /// final mapped = either.mapLeft((value) => value * 2);
  /// expect(mapped, Left('error'));
  /// ```
  Either<T, R> mapLeft<T>(T Function(L) f);

  /// Maps a [Right] value to a new [Either].
  ///
  /// If the [Either] is a [Left], it returns the same [Left].
  ///
  /// ```dart
  /// final either = Right(1);
  /// final mapped = either.flatMap((value) => Right(value * 2));
  /// expect(mapped, Right(2));
  /// ```
  Either<L, T> flatMap<T>(Either<L, T> Function(R) f);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      switch ((this, other)) {
        (Right(:final value), Right(value: final otherValue)) => value == otherValue,
        (Left(:final value), Left(value: final otherValue)) => value == otherValue,
        (_, _) => false,
      };

  @override
  int get hashCode => switch (this) {
        Left(:final value) => value.hashCode,
        Right(:final value) => value.hashCode,
      };

  @override
  String toString() => switch (this) {
        Left(:final value) => 'Left($value)',
        Right(:final value) => 'Right($value)',
      };
}

class Left<L, R> extends Either<L, R> {
  const Left(this.value) : super._();

  final L value;

  @override
  Either<L, T> map<T>(T Function(R) f) => Left(value);

  @override
  Either<T, R> mapLeft<T>(T Function(L) f) => Left(f(value));

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R) f) => Left(value);
}

class Right<L, R> extends Either<L, R> {
  const Right(this.value) : super._();

  final R value;

  @override
  Either<L, T> map<T>(T Function(R) f) => Right(f(value));

  @override
  Either<T, R> mapLeft<T>(T Function(L) f) => Right(value);

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R) f) => f(value);
}
