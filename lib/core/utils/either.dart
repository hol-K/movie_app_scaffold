/// Implémentation minimale du pattern `Either<L, R>`, suffisante pour ce
/// projet. On évite d'ajouter `dartz` comme dépendance juste pour ce type.
/// `L` = Left = échec (par convention, un [Failure]), `R` = Right = succès.
sealed class Either<L, R> {
  const Either();

  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    final self = this;
    if (self is Left<L, R>) return onLeft(self.value);
    return onRight((self as Right<L, R>).value);
  }

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
}
