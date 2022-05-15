class SimpleRouteIdentifier {
  SimpleRouteIdentifier({
    required this.name,
    this.args,
  });

  final String name;
  final Object? args;

  @override
  String toString() => 'SimpleRouteIdentifier{routeName: $name, args: $args}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimpleRouteIdentifier &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          args == other.args;

  @override
  int get hashCode => name.hashCode ^ args.hashCode;
}
