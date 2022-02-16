extension ListX<T> on List<T> {
  void popUntil(bool Function(T e) test) {
    for (int i = length - 1; i >= 0; i--) {
      if (test(this[i])) {
        break;
      }
      removeAt(i);
    }
  }

  void assign(T item) {
    clear();
    add(item);
  }
}
